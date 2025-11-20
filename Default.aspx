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
                            iframe.contentWindow.postMessage(JSON.stringify({
                                action: 'load',
                                autosave: 1,
                                xml: diagramXml
                            }), '*');
                        } else {
                            // For new diagram, load empty diagram XML
                            console.log('Starting with empty diagram');
                            var emptyDiagram = '<mxfile host="app.diagrams.net"><diagram id="new"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel></diagram></mxfile>';
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
                            diagramXml = msg.xml;
                            console.log('Diagram XML updated with new structure');
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

