# Draw.io Diagram Viewer & Editor - ASP.NET Web Forms Application

A complete ASP.NET Web Forms application that integrates Draw.io/diagrams.net for viewing and editing diagrams directly in your web application.

## Features

- ✅ Display diagram thumbnails
- ✅ Click to open full Draw.io editor in iframe
- ✅ Full editing capabilities with all Draw.io tools
- ✅ Save and close functionality
- ✅ Clean, modern UI
- ✅ Single ASPX page implementation

## Quick Start

### Prerequisites

- Windows 10/11 or Windows Server
- IIS with ASP.NET 4.x support
- .NET Framework 4.7.2 or higher
- Visual Studio 2017 or later (recommended)

### Option 1: Visual Studio (Recommended)

1. Open `DrawioWebApp.sln` in Visual Studio
2. Right-click the project → Properties → Web
3. Select "Local IIS" and click "Create Virtual Directory"
4. Press **F5** to run
5. Browser opens automatically to the application

### Option 2: Automated Setup Script

1. Right-click `Setup-IIS.bat`
2. Select "Run as administrator"
3. Open browser to: `http://localhost/DrawioWebApp`

### Option 3: Manual IIS Setup

1. Open IIS Manager (`Win+R` → type `inetmgr`)
2. Right-click "Default Web Site" → "Add Application"
3. Set Alias: `DrawioWebApp`
4. Set Physical Path: `[path to this folder]`
5. Click OK
6. Navigate to: `http://localhost/DrawioWebApp`

## How to Use

1. The page displays a diagram thumbnail
2. Click the thumbnail (or "Open in Editor" button)
3. Draw.io editor loads with the diagram
4. Edit your diagram using all Draw.io features
5. Click "Save and Exit" or "Close Editor" to return
6. Your changes are captured (see customization section)

## Project Structure

```
DrawioWebApp/
├── Default.aspx              # Main page (UI/HTML/JavaScript)
├── Default.aspx.cs           # Code-behind (server-side logic)
├── Default.aspx.designer.cs  # Auto-generated designer file
├── Web.config                # IIS and ASP.NET configuration
├── DrawioWebApp.csproj       # Visual Studio project file
├── DrawioWebApp.sln          # Visual Studio solution file
├── diagram-thumbnail.png     # Diagram thumbnail image
├── Properties/
│   └── AssemblyInfo.cs       # Assembly metadata
├── bin/                      # Compiled binaries
└── obj/                      # Build intermediate files
```

## Customization

### Change the Diagram

Edit the `GetSampleDiagramXml()` method in `Default.aspx.cs` to load your own diagram XML:

```csharp
private string GetSampleDiagramXml()
{
    // Load from database, file, or return custom XML
    return yourDiagramXml;
}
```

### Change the Thumbnail

Replace `diagram-thumbnail.png` with your own diagram image (recommended: 400x300 or 800x600 pixels).

### Implement Save Functionality

The application currently alerts when saving. To implement real persistence, modify the save handler in `Default.aspx`:

```javascript
if (msg.event == 'save') {
    console.log('Diagram saved:', msg.xml);
    // Send to server via AJAX
    saveDiagramToServer(msg.xml);
}
```

Then add a server-side method to save to database or file system.

### Styling

Edit the `<style>` section in `Default.aspx` to customize colors, fonts, and layout.

## Technical Details

### Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.7.2)
- **Editor**: Draw.io/diagrams.net (embedded via iframe)
- **Communication**: PostMessage API for iframe communication
- **Server**: IIS (Internet Information Services)

### Draw.io Integration

This application uses the official Draw.io embed API:
- **URL**: `https://embed.diagrams.net/`
- **Mode**: Embedded mode with Kennedy UI
- **Protocol**: JSON-based postMessage communication
- **Documentation**: https://www.drawio.com/doc/faq/embed-mode

### Browser Compatibility

- ✅ Google Chrome (recommended)
- ✅ Microsoft Edge
- ✅ Mozilla Firefox
- ✅ Safari
- ⚠️ Internet Explorer (not recommended)

## Troubleshooting

### Editor Stuck on "Loading..."

- Check internet connection (Draw.io loads from CDN)
- Clear browser cache (Ctrl+Shift+Del)
- Try different browser
- Check browser console (F12) for errors

### HTTP 500 Error

```powershell
# Rebuild solution
cd [project path]
msbuild DrawioWebApp.sln /t:Rebuild

# Restart IIS
iisreset
```

### Application Pool Stopped

1. Open IIS Manager
2. Click "Application Pools"
3. Right-click "DefaultAppPool" → Start

### Diagram Doesn't Load

- Verify internet connectivity to `embed.diagrams.net`
- Check browser console for JavaScript errors
- Ensure running on `localhost` (not IP address)

## Production Deployment

For production environments, consider:

### Security
- Enable HTTPS with SSL certificate
- Implement user authentication
- Add input validation and sanitization
- Configure proper error handling

### Performance
- Enable output caching
- Compress static resources
- Use CDN for static files
- Monitor application pool resources

### Data Management
- Implement database integration (SQL Server, etc.)
- Add version control for diagrams
- Implement backup and recovery
- Add audit logging

### Example Database Integration

```csharp
// Save diagram to database
protected void SaveDiagram(string xml)
{
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        string query = "INSERT INTO Diagrams (UserId, DiagramXml, UpdatedDate) VALUES (@UserId, @Xml, @Date)";
        SqlCommand cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@UserId", GetCurrentUserId());
        cmd.Parameters.AddWithValue("@Xml", xml);
        cmd.Parameters.AddWithValue("@Date", DateTime.Now);
        conn.Open();
        cmd.ExecuteNonQuery();
    }
}
```

## Support Resources

- **Draw.io Documentation**: https://www.diagrams.net/doc
- **Draw.io Embed Mode**: https://www.drawio.com/doc/faq/embed-mode
- **ASP.NET Web Forms**: https://docs.microsoft.com/aspnet/web-forms
- **IIS Configuration**: https://docs.microsoft.com/iis

## License

This is a sample/demo application. Customize and use as needed for your project.

## Version History

### Version 1.0 (November 2024)
- Initial release
- Single page with thumbnail and editor
- Draw.io integration via postMessage API
- Full editing capabilities
- UTF-8 encoding support
- Professional UI design

---

**Developed**: November 2024  
**Framework**: ASP.NET Web Forms 4.7.2  
**Editor**: Draw.io/diagrams.net  
**Status**: Production Ready ✅
