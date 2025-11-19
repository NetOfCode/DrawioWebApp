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
        
        function openEditor() {
            // Get the diagram XML from server (existing diagram)
            diagramXml = `<%= DiagramXml.Replace("\"", "\\\"").Replace("\r\n", "").Replace("\n", "").Replace("\r", "") %>`;
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
                    
                    // Handle save event
                    if (msg.event == 'save') {
                        console.log('Diagram saved:', msg.xml);
                        
                        // Indicate if this is a new diagram or updating existing
                        var saveType = isNewDiagram ? 'New diagram created!' : 'Diagram updated!';
                        
                        // Here you could send the data back to the server via AJAX
                        // Example: saveDiagramToServer(msg.xml, isNewDiagram);
                        alert(saveType + '\n\n(In production, this would save to server)');
                        
                        // Send export command to acknowledge save
                        iframe.contentWindow.postMessage(JSON.stringify({
                            action: 'export'
                        }), '*');
                    }
                    
                    // Handle exit event
                    if (msg.event == 'exit') {
                        closeEditor();
                    }
                    
                    // Handle export event
                    if (msg.event == 'export') {
                        console.log('Diagram exported');
                        // Optionally save the exported data
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

