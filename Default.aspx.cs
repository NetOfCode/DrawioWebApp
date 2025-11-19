using System;
using System.Web;
using System.Web.UI;

namespace DrawioWebApp
{
    public partial class Default : System.Web.UI.Page
    {
        // This will be accessible from the ASPX page
        public string DiagramXml { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load the sample diagram data
                // In production, this would come from a database or file system
                DiagramXml = GetSampleDiagramXml();
            }
        }

        /// <summary>
        /// Returns a sample draw.io diagram XML
        /// In production, this would load from a database or file
        /// </summary>
        private string GetSampleDiagramXml()
        {
            // Sample draw.io diagram XML (a simple flowchart)
            // Using single quotes for attributes to avoid escaping issues
            return @"<mxfile host='app.diagrams.net' modified='2024-01-01T00:00:00.000Z' agent='5.0' version='21.1.2' etag='sample' type='device'><diagram name='Sample Flowchart' id='sample'><mxGraphModel dx='1422' dy='794' grid='1' gridSize='10' guides='1' tooltips='1' connect='1' arrows='1' fold='1' page='1' pageScale='1' pageWidth='850' pageHeight='1100' math='0' shadow='0'><root><mxCell id='0'/><mxCell id='1' parent='0'/><mxCell id='2' value='Start' style='rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;' vertex='1' parent='1'><mxGeometry x='370' y='40' width='120' height='60' as='geometry'/></mxCell><mxCell id='3' value='Process Data' style='rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;' vertex='1' parent='1'><mxGeometry x='370' y='140' width='120' height='60' as='geometry'/></mxCell><mxCell id='4' value='Is Valid?' style='rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;' vertex='1' parent='1'><mxGeometry x='360' y='240' width='140' height='80' as='geometry'/></mxCell><mxCell id='5' value='Save to Database' style='rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;' vertex='1' parent='1'><mxGeometry x='370' y='360' width='120' height='60' as='geometry'/></mxCell><mxCell id='6' value='Show Error' style='rounded=0;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;' vertex='1' parent='1'><mxGeometry x='560' y='250' width='120' height='60' as='geometry'/></mxCell><mxCell id='7' value='End' style='rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;' vertex='1' parent='1'><mxGeometry x='370' y='460' width='120' height='60' as='geometry'/></mxCell><mxCell id='8' value='' style='endArrow=classic;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;' edge='1' parent='1' source='2' target='3'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/></mxGeometry></mxCell><mxCell id='9' value='' style='endArrow=classic;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;' edge='1' parent='1' source='3' target='4'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/></mxGeometry></mxCell><mxCell id='10' value='' style='endArrow=classic;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;' edge='1' parent='1' source='4' target='5'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/></mxGeometry></mxCell><mxCell id='11' value='Yes' style='edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];' vertex='1' connectable='0' parent='10'><mxGeometry x='-0.2' y='2' relative='1' as='geometry'><mxPoint as='offset'/></mxGeometry></mxCell><mxCell id='12' value='' style='endArrow=classic;html=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;' edge='1' parent='1' source='4' target='6'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/></mxGeometry></mxCell><mxCell id='13' value='No' style='edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];' vertex='1' connectable='0' parent='12'><mxGeometry x='-0.2' y='2' relative='1' as='geometry'><mxPoint as='offset'/></mxGeometry></mxCell><mxCell id='14' value='' style='endArrow=classic;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;' edge='1' parent='1' source='5' target='7'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/></mxGeometry></mxCell><mxCell id='15' value='' style='endArrow=classic;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=1;entryY=0.5;entryDx=0;entryDy=0;' edge='1' parent='1' source='6' target='7'><mxGeometry width='50' height='50' relative='1' as='geometry'><mxPoint x='400' y='400' as='sourcePoint'/><mxPoint x='450' y='350' as='targetPoint'/><Array as='points'><mxPoint x='620' y='490'/></Array></mxGeometry></mxCell></root></mxGraphModel></diagram></mxfile>";
        }
    }
}

