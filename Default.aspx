<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DrawioWebApp.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Draw.io Diagram Viewer</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #ff6b00;
            padding-bottom: 10px;
        }
        .thumbnail-container {
            text-align: center;
            margin: 30px 0;
        }
        .diagram-thumbnail {
            max-width: 400px;
            border: 2px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .diagram-thumbnail:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .instruction {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .editor-container {
            display: none;
            margin-top: 20px;
        }
        .editor-container.active {
            display: block;
        }
        #diagramEditor {
            width: 100%;
            height: 800px;
            border: 2px solid #ff6b00;
            border-radius: 4px;
        }
        .button-container {
            text-align: center;
            margin-top: 20px;
        }
        .btn {
            background-color: #ff6b00;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin: 0 10px;
        }
        .btn:hover {
            background-color: #e55d00;
        }
        .btn-secondary {
            background-color: #666;
        }
        .btn-secondary:hover {
            background-color: #555;
        }
    </style>
    <script type="text/javascript">
        var iframe = null;
        var diagramXml = null;
        var isNewDiagram = false;
        var exportedImageData = null; // Variable to store the exported PNG image data (base64)
        var diagramName = 'Untitled Diagram'; // Store diagram name
        
        function openEditor() {
            // Use saved diagram XML if available, otherwise use server-side default
            if (!diagramXml) {
                // Get the diagram XML from server (only if not already saved)
                diagramXml = `<%= DiagramXml.Replace("\"", "\\\"").Replace("\r\n", "").Replace("\n", "").Replace("\r", "") %>`;
                console.log('Loading initial diagram from server');
            } else {
                console.log('Loading saved diagram structure (last changes)');
            }
            isNewDiagram = false;
            
            // Build the diagrams.net URL with embedded mode
            var editorUrl = 'https://embed.diagrams.net/?embed=1&ui=kennedy&spin=1&proto=json&saveAndExit=1&noSaveBtn=0';
            
            // Get iframe reference
            iframe = document.getElementById('diagramEditor');
            
            // Set iframe source
            iframe.src = editorUrl;
            
            // Hide thumbnail, show editor
            document.getElementById('thumbnailSection').style.display = 'none';
            document.getElementById('editorSection').classList.add('active');
        }

        function createNewDiagram() {
            // Create empty diagram (no XML data)
            diagramXml = null;
            isNewDiagram = true;
            
            // Build the diagrams.net URL with embedded mode
            var editorUrl = 'https://embed.diagrams.net/?embed=1&ui=kennedy&spin=1&proto=json&saveAndExit=1&noSaveBtn=0';
            
            // Get iframe reference
            iframe = document.getElementById('diagramEditor');
            
            // Set iframe source
            iframe.src = editorUrl;
            
            // Hide thumbnail, show editor
            document.getElementById('thumbnailSection').style.display = 'none';
            document.getElementById('editorSection').classList.add('active');
        }

        /**
         * Extracts diagram name from XML
         */
        function extractDiagramName(xml) {
            try {
                if (!xml) return 'Untitled Diagram';
                
                // Try to find diagram name in XML
                // Pattern: <diagram name="DiagramName" or name='DiagramName'
                var nameMatch = xml.match(/<diagram[^>]*name=["']([^"']+)["']/i);
                if (nameMatch && nameMatch[1]) {
                    return nameMatch[1];
                }
                
                // Try alternative pattern
                nameMatch = xml.match(/name=["']([^"']+)["'][^>]*>/i);
                if (nameMatch && nameMatch[1]) {
                    return nameMatch[1];
                }
                
                return 'Untitled Diagram';
            } catch(e) {
                console.error('Error extracting diagram name:', e);
                return 'Untitled Diagram';
            }
        }
        
        /**
         * Updates diagram name in the XML
         * More robust version that preserves XML structure
         */
        function updateDiagramNameInXml(xml, newName) {
            try {
                if (!xml || !newName) return xml;
                
                // Escape XML special characters in the new name
                var escapedName = newName
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&apos;');
                
                // More precise pattern: match <diagram followed by attributes, then name="value" or name='value'
                // Pattern 1: name="value" (double quotes)
                var updatedXml = xml.replace(/<diagram([^>]*\s)name=["']([^"']*)["']([^>]*>)/i, 
                    function(match, before, oldName, after) {
                        return '<diagram' + before + 'name="' + escapedName + '"' + after;
                    });
                
                // Pattern 2: name='value' (single quotes) - if first pattern didn't match
                if (updatedXml === xml) {
                    updatedXml = xml.replace(/<diagram([^>]*\s)name=['"]([^'"]*)['"]([^>]*>)/i, 
                        function(match, before, oldName, after) {
                            return '<diagram' + before + 'name="' + escapedName + '"' + after;
                        });
                }
                
                // Pattern 3: name attribute at the start of <diagram tag
                if (updatedXml === xml) {
                    updatedXml = xml.replace(/<diagram\s+name=["']([^"']*)["']([^>]*>)/i, 
                        function(match, oldName, after) {
                            return '<diagram name="' + escapedName + '"' + after;
                        });
                }
                
                // If no name attribute exists, add it after <diagram
                if (updatedXml === xml) {
                    // Find the first <diagram tag and add name attribute
                    updatedXml = xml.replace(/<diagram(\s+[^>]*>)/i, 
                        function(match, rest) {
                            // Check if name already exists (shouldn't happen, but safety check)
                            if (rest.indexOf('name=') === -1) {
                                return '<diagram name="' + escapedName + '"' + rest;
                            }
                            return match;
                        });
                }
                
                // Validate that the XML structure is still intact
                // Check that we still have <mxfile> and <diagram> tags
                if (updatedXml.indexOf('<mxfile') === -1 || updatedXml.indexOf('</mxfile>') === -1) {
                    console.error('ERROR: XML structure broken - missing mxfile tags');
                    return xml; // Return original on error
                }
                
                if (updatedXml.indexOf('<diagram') === -1 || updatedXml.indexOf('</diagram>') === -1) {
                    console.error('ERROR: XML structure broken - missing diagram tags');
                    return xml; // Return original on error
                }
                
                console.log('XML name update successful - Original length:', xml.length, 'Updated length:', updatedXml.length);
                console.log('New name:', newName, 'Escaped:', escapedName);
                
                // Log a snippet to verify structure
                var snippet = updatedXml.substring(0, Math.min(200, updatedXml.length));
                console.log('XML snippet (first 200 chars):', snippet);
                
                return updatedXml;
            } catch(e) {
                console.error('Error updating diagram name in XML:', e);
                console.error('XML snippet:', xml.substring(0, 200));
                return xml; // Return original on error
            }
        }
        
        /**
         * Updates diagram name when user changes it in the input field
         */
        function updateDiagramName(newName) {
            diagramName = newName || 'Untitled Diagram';
            console.log('Diagram name updated to:', diagramName);
            
            // If diagram is loaded, update the XML with new name
            if (diagramXml && iframe) {
                // Update the XML with new name
                diagramXml = updateDiagramNameInXml(diagramXml, diagramName);
                console.log('Diagram XML updated with new name');
                
                // Optionally reload the diagram in editor with new name
                // (This is optional - the name will be saved when user saves)
            }
        }
        
        function closeEditor() {
            // Hide editor, show thumbnail
            document.getElementById('editorSection').classList.remove('active');
            document.getElementById('thumbnailSection').style.display = 'block';
            
            // Clear iframe source
            iframe.src = 'about:blank';
            iframe = null;
            isNewDiagram = false;
        }

        // Listen for messages from the draw.io iframe
        window.addEventListener('message', function(evt) {
            if (evt.data && evt.data.length > 0 && iframe) {
                try {
                    var msg = JSON.parse(evt.data);
                    
                    // Handle init event - sent when editor is ready
                    if (msg.event == 'init') {
                        console.log('Draw.io editor initialized');
                        
                        // If opening existing diagram, load the XML
                        if (!isNewDiagram && diagramXml) {
                            // Extract and display diagram name
                            diagramName = extractDiagramName(diagramXml);
                            var nameInput = document.getElementById('diagramNameInput');
                            if (nameInput) {
                                nameInput.value = diagramName;
                            }
                            console.log('Diagram name extracted:', diagramName);
                            
                            iframe.contentWindow.postMessage(JSON.stringify({
                                action: 'load',
                                autosave: 1,
                                xml: diagramXml
                            }), '*');
                        } else {
                            // For new diagram, load empty diagram XML
                            console.log('Starting with empty diagram');
                            diagramName = 'Untitled Diagram';
                            var nameInput = document.getElementById('diagramNameInput');
                            if (nameInput) {
                                nameInput.value = diagramName;
                            }
                            
                            var emptyDiagram = '<mxfile host="app.diagrams.net"><diagram id="new" name="' + diagramName + '"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel></diagram></mxfile>';
                            iframe.contentWindow.postMessage(JSON.stringify({
                                action: 'load',
                                autosave: 1,
                                xml: emptyDiagram
                            }), '*');
                        }
                    }
                    
                    // Handle configure event
                    if (msg.event == 'configure') {
                        console.log('Draw.io editor configured');
                        iframe.contentWindow.postMessage(JSON.stringify({
                            action: 'configure',
                            config: {
                                defaultEdgeStyle: { edgeStyle: 'orthogonalEdgeStyle' }
                            }
                        }), '*');
                    }
                    
                    // Received if the user clicks save
                    else if (msg.event == 'save') {
                        console.log('Save event received, requesting XMLPNG export...');
                        console.log('Diagram XML:', msg.xml);
                        
                        // IMPORTANT: Update diagramXml with the new structure so it loads next time
                        if (msg.xml) {
                            // Store the XML from Draw.io first (it already has the correct structure)
                            diagramXml = msg.xml;
                            console.log('Diagram XML received from Draw.io, length:', diagramXml.length);
                            
                            // Then update the name in the stored XML
                            // Only update if name was changed (to avoid unnecessary processing)
                            var currentNameInXml = extractDiagramName(diagramXml);
                            console.log('Current name in XML:', currentNameInXml, 'Desired name:', diagramName);
                            
                            if (currentNameInXml !== diagramName) {
                                console.log('Updating diagram name from "' + currentNameInXml + '" to "' + diagramName + '"');
                                var xmlBefore = diagramXml;
                                diagramXml = updateDiagramNameInXml(diagramXml, diagramName);
                                
                                // Verify the update worked
                                var nameAfter = extractDiagramName(diagramXml);
                                if (nameAfter === diagramName) {
                                    console.log('✓ Diagram name successfully updated');
                                } else {
                                    console.error('✗ Diagram name update failed! Expected:', diagramName, 'Got:', nameAfter);
                                    console.error('Reverting to original XML');
                                    diagramXml = xmlBefore; // Revert on failure
                                }
                            } else {
                                console.log('Diagram name unchanged, no update needed');
                            }
                            
                            isNewDiagram = false; // Mark as existing diagram (not new anymore)
                        }
                        
                        // Sends a request to export the diagram as XML with embedded PNG so we can store it in the database
                        // Try different export formats - Draw.io might use different format names
                        iframe.contentWindow.postMessage(JSON.stringify({
                            action: 'export',
                            format: 'xmlpng',
                            spinKey: 'saving'
                        }), '*');
                        
                        // Also try without format to see what Draw.io returns
                        console.log('Export request sent with format: xmlpng');
                    }
                    
                    // Received if the export request was processed
                    else if (msg.event == 'export') {
                        console.log('Export event received');
                        console.log('Full export message:', msg);
                        console.log('msg.data type:', typeof msg.data);
                        console.log('msg.data length:', msg.data ? msg.data.length : 'null/undefined');
                        
                        // Check different possible data formats
                        var imageDataUri = null;
                        var base64Data = null;
                        
                        // Try msg.data (could be base64 string or full data URI)
                        if (msg.data && typeof msg.data === 'string') {
                            // Check if it's already a data URI
                            if (msg.data.indexOf('data:image') === 0) {
                                // It's already a full data URI - use it directly
                                imageDataUri = msg.data;
                                // Extract just the base64 part for storage (without the prefix)
                                var base64Match = msg.data.match(/data:image\/png;base64,(.+)/);
                                if (base64Match && base64Match[1]) {
                                    base64Data = base64Match[1];
                                } else {
                                    // Fallback: use the whole string if extraction fails
                                    base64Data = msg.data;
                                }
                                console.log('Found image data in msg.data (full data URI)');
                            } else {
                                // It's just base64, need to add data URI prefix
                                base64Data = msg.data;
                                imageDataUri = 'data:image/png;base64,' + msg.data;
                                console.log('Found image data in msg.data (base64 only, added prefix)');
                            }
                        }
                        // Try msg.xml (if it's the XMLPNG format)
                        else if (msg.xml && typeof msg.xml === 'string' && msg.xml.indexOf('data:image') !== -1) {
                            // Extract base64 from data URI
                            var base64Match = msg.xml.match(/data:image\/png;base64,(.+)/);
                            if (base64Match && base64Match[1]) {
                                base64Data = base64Match[1];
                                imageDataUri = msg.xml;
                                console.log('Found image data in msg.xml (extracted from data URI)');
                            }
                        }
                        // Try msg.dataUri
                        else if (msg.dataUri && typeof msg.dataUri === 'string') {
                            var base64Match = msg.dataUri.match(/data:image\/png;base64,(.+)/);
                            if (base64Match && base64Match[1]) {
                                base64Data = base64Match[1];
                                imageDataUri = msg.dataUri;
                                console.log('Found image data in msg.dataUri (extracted from data URI)');
                            }
                        }
                        
                        // Updates the data URI of the image
                        if (imageDataUri && base64Data) {
                            // Capture the exported image data in JavaScript variable (store just base64)
                            exportedImageData = base64Data;
                            console.log('New image data captured and stored in exportedImageData variable');
                            console.log('Data size:', exportedImageData.length, 'characters');
                            
                            // Update the thumbnail image with the new exported PNG (override old image)
                            var thumbnail = document.querySelector('.diagram-thumbnail');
                            if (thumbnail) {
                                // Override old image with new one (use the full data URI)
                                thumbnail.src = imageDataUri;
                                console.log('Thumbnail image updated with new exported PNG (old image overridden)');
                                
                                // Show the thumbnail (in case it was hidden)
                                thumbnail.style.display = '';
                                var noImageDiv = document.getElementById('noImage');
                                if (noImageDiv) {
                                    noImageDiv.style.display = 'none';
                                }
                            }
                            
                            // The exportedImageData variable now contains the new base64 PNG data
                            // This replaces/overrides the old image data
                            console.log('New image structure saved successfully!');
                            console.log('You can access the data via: exportedImageData');
                            
                            // After export completes, close the editor automatically
                            // This handles the "Save and Exit" flow
                            console.log('Closing editor after successful export...');
                            setTimeout(function() {
                                closeEditor();
                            }, 100); // Small delay to ensure image update completes
                        } else {
                            console.warn('Export event received but could not extract image data');
                            console.warn('Available properties:', Object.keys(msg));
                            console.warn('Full message object:', JSON.stringify(msg, null, 2));
                        }
                    }
                    
                    // Received if the user clicks exit or after export
                    if (msg.event == 'exit') {
                        console.log('Exit event received, closing editor...');
                        // Closes the editor
                        closeEditor();
                    }
                } catch(e) {
                    // Ignore non-JSON messages
                    console.log('Non-JSON message received:', evt.data);
                }
            }
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>🎨 Draw.io Diagram Viewer & Editor</h1>
            
            <!-- Thumbnail Section -->
            <div id="thumbnailSection" class="thumbnail-container">
                <p class="instruction">
                    <strong>Click or double-click the diagram below to open the editor</strong>
                </p>
                <img src="diagram-thumbnail.png" 
                     alt="Diagram Thumbnail" 
                     class="diagram-thumbnail"
                     onclick="openEditor()"
                     ondblclick="openEditor()"
                     onerror="this.style.display='none';document.getElementById('noImage').style.display='block';" />
                <div id="noImage" style="display:none; padding:40px; background:#f0f0f0; border:2px dashed #ccc; border-radius:8px; cursor:pointer;" onclick="openEditor()">
                    <h2 style="color:#666;">📊 Sample Flowchart Diagram</h2>
                    <p style="color:#999;">Click here to open the Draw.io editor</p>
                    <p style="color:#999; font-size:12px;">(Thumbnail image will be generated after first save)</p>
                </div>
                <div class="button-container">
                    <button type="button" class="btn" onclick="openEditor()">Open Existing Diagram</button>
                    <button type="button" class="btn" onclick="createNewDiagram()">Create New Diagram</button>
                </div>
            </div>
            
            <!-- Editor Section -->
            <div id="editorSection" class="editor-container">
                <div style="margin-bottom: 15px; padding: 10px; background-color: #f9f9f9; border-radius: 4px;">
                    <label for="diagramNameInput" style="display: block; margin-bottom: 5px; font-weight: bold; color: #333;">Diagram Name:</label>
                    <input type="text" 
                           id="diagramNameInput" 
                           value="Untitled Diagram" 
                           style="width: 100%; max-width: 500px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;"
                           onchange="updateDiagramName(this.value)"
                           placeholder="Enter diagram name" />
                    <p style="margin-top: 5px; font-size: 12px; color: #666;">The diagram name is stored in the diagram and will be saved when you save the diagram.</p>
                </div>
                <p class="instruction">
                    <strong>Edit your diagram below. Click "Save and Exit" in the editor or the button below to return.</strong>
                </p>
                <iframe id="diagramEditor"></iframe>
                <div class="button-container">
                    <button type="button" class="btn btn-secondary" onclick="closeEditor()">Close Editor</button>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

