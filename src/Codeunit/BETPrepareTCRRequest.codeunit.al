/// <summary>
/// Codeunit BET MyCodeunit (ID 50002).
/// </summary>
codeunit 50002 "BET Prepare TCR Request"
{
    var
        PrepareXMLRequest: Codeunit "BET Prepare XML Request";
        RequestMgt: Codeunit "BET Request Mgt";
        XmlinSchemaLbl: Label 'https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema', Locked = true;
        FiscNamespaceUriLbl: Label 'https://efiskalizimi-test.tatime.gov.al:443/FiscalizationService-v3/', Locked = true;
        FiscActionUriLbl: Label 'RegisterTCR', Locked = true;


    /// <summary>
    /// PrepareRequest.
    /// </summary>
    procedure PrepareTCRRequest()
    var
        DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper";
        SigningMgt: Codeunit "BET Signing Mgt";
        BaseXMLRequest: XmlDocument;
        BodyNode: XmlNode;
        SignatureXML: XmlElement;
        ContentToSend: Text;
        ContentType: Text;
        Result: Text;
        BodyXPath2Lbl: Label '/*[local-name()="Envelope"]/*[local-name()="Body"]/*[local-name()="RegisterTCRRequest"]', Locked = true;
    begin
        BaseXMLRequest := PrepareXMLRequest.CreateBaseRequest('RegisterTCRRequest', XmlinSchemaLbl);
        BaseXMLRequest.SelectSingleNode(BodyXPath2Lbl, BodyNode);
        BodyNode.AsXmlElement().Add(CreateTCRRegisterXML(XmlinSchemaLbl));
        SignatureXML := SigningMgt.GenerateSigning(BaseXMLRequest, 'TEST_CERTIFICATE', XmlinSchemaLbl);
        BaseXMLRequest.SelectSingleNode(BodyXPath2Lbl, BodyNode);
        BodyNode.AsXmlElement().Add(SignatureXML);

        BaseXMLRequest.WriteTo(ContentToSend);
        DictionaryWrapperDefaultHeaders.Set('SOAPAction', FiscNamespaceUriLbl + FiscActionUriLbl);
        ContentType := 'text/xml; charset="utf-8"';

        Message(ContentToSend);

        Result := RequestMgt.SendAPIRequest(ContentToSend, ContentType, FiscNamespaceUriLbl, FiscActionUriLbl, DictionaryWrapperDefaultHeaders);
        Message(Result);
    end;

    /// <summary>
    /// CreateRegisterCashDepositXMLDoc.
    /// </summary>
    /// <param name="XmlniSchema">Text.</param>
    /// <returns>Return value of type XmlDocument.</returns>
    procedure CreateTCRRegisterXML(XmlniSchema: Text): XmlElement
    var
        TCREl: XmlElement;
    begin
        TCREl := XmlElement.Create('TCR', XmlniSchema);
        TCREl.SetAttribute('BusinUnitCode', 'aa000aa000');
        TCREl.SetAttribute('IssuerNUIS', 'L00000000A');
        TCREl.SetAttribute('MaintainerCode', 'ee000ee000');
        TCREl.SetAttribute('SoftCode', 'cc000cc000');
        TCREl.SetAttribute('TCRIntID', '2');
        TCREl.SetAttribute('ValidFrom', '2026-08-31');
        TCREl.SetAttribute('Type', 'REGULAR');

        exit(TCREl);
    end;
}