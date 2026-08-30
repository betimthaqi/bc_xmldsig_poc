/// <summary>
/// Codeunit BET MyCodeunit (ID 50002).
/// </summary>
codeunit 50005 "BET Prepare XML Request"
{
    /// <summary>
    /// CreateBaseXMLDoc.
    /// </summary>
    /// <param name="RequestTag">Text.</param>
    /// <param name="XmlinSchema">Text.</param>
    /// <returns>Return value of type XmlDocument.</returns>
    procedure CreateBaseRequest(RequestTag: Text; XmlinSchema: Text): XmlDocument
    var
        BaseXMLDoc: XmlDocument;
        RequestEl: XmlElement;
        BodyNode: XmlNode;
        BodyXPathLbl: Label '/*[local-name()="Envelope"]/*[local-name()="Body"]', Locked = true;
    begin
        RequestEl := XmlElement.Create(RequestTag, XmlinSchema);
        RequestEl.SetAttribute('Id', 'Request');
        RequestEl.SetAttribute('Version', '3');
        RequestEl.Add(GetHeaderElement(XmlinSchema));

        BaseXMLDoc := CreateBaseXMLDoc();
        BaseXMLDoc.SelectSingleNode(BodyXPathLbl, BodyNode);
        BodyNode.AsXmlElement().Add(RequestEl);
        exit(BaseXMLDoc);
    end;

    /// <summary>
    /// CreateBaseXMLDoc.
    /// </summary>
    /// <returns>Return value of type XmlDocument.</returns>
    procedure CreateBaseXMLDoc(): XmlDocument
    var
        XMLDoc: XmlDocument;
        XMLDec: XmlDeclaration;
        XMLElem: XmlElement;
        XMLElem2: XmlElement;
        XMLAtr: XmlAttribute;
    begin
        XMLDoc := XmlDocument.Create();

        XMLDec := XmlDeclaration.Create('1.0', 'UTF-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        xmlElem := xmlElement.Create('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');

        XMLAtr := XmlAttribute.CreateNamespaceDeclaration('SOAP-ENV', 'http://schemas.xmlsoap.org/soap/envelope/');
        XMLElem.Add(XMLAtr);

        xmlElem2 := XmlElement.Create('Header', 'http://schemas.xmlsoap.org/soap/envelope/');
        xmlElem.Add(xmlElem2);

        Clear(xmlElem2);
        xmlElem2 := XmlElement.Create('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        xmlElem2.Add(xmlText.Create(''));

        xmlElem.Add(xmlElem2);
        xmlDoc.Add(xmlElem);

        exit(XMLDoc);
    end;

    /// <summary>
    /// GetHeaderElement.
    /// </summary>
    /// <param name="XmlinSchema">Text.</param>
    /// <returns>Return value of type XmlElement.</returns>
    procedure GetHeaderElement(XmlinSchema: Text): XmlElement
    var
        FiscTypeHelper: Codeunit "BET FISC Type Helper";
        HeaderEl: XmlElement;
    begin
        HeaderEl := XmlElement.Create('Header', XmlinSchema);
        HeaderEl.SetAttribute('UUID', FiscTypeHelper.CreateUUID());
        HeaderEl.SetAttribute('SendDateTime', FiscTypeHelper.GetCurrentUTCDateTime());
        exit(HeaderEl);
    end;
}