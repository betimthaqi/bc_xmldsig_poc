/// <summary>
/// Codeunit BET Prepare Invoice Request (ID 50004).
/// </summary>
codeunit 50004 "BET Prepare Invoice Request"
{
    var
        FiscTypeHelper: Codeunit "BET FISC Type Helper";
        PrepareXMLRequest: Codeunit "BET Prepare XML Request";
        RequestMgt: Codeunit "BET Request Mgt";
        XmlinSchemaLbl: Label 'https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema', Locked = true;
        FiscNamespaceUriLbl: Label 'https://efiskalizimi-test.tatime.gov.al:443/FiscalizationService-v3/', Locked = true;
        FiscActionUriLbl: Label 'RegisterInvoice', Locked = true;

    /// <summary>
    /// PrepareRequest.
    /// </summary>
    procedure PrepareInvoiceRequest()
    var
        DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper";
        SigningMgt: Codeunit "BET Signing Mgt";
        BaseXMLRequest: XmlDocument;
        BodyNode: XmlNode;
        SignatureXML: XmlElement;
        ContentToSend: Text;
        ContentType: Text;
        Result: Text;
        BodyXPath2Lbl: Label '/*[local-name()="Envelope"]/*[local-name()="Body"]/*[local-name()="RegisterInvoiceRequest"]', Locked = true;
    begin
        BaseXMLRequest := PrepareXMLRequest.CreateBaseRequest('RegisterInvoiceRequest', XmlinSchemaLbl);
        BaseXMLRequest.SelectSingleNode(BodyXPath2Lbl, BodyNode);
        BodyNode.AsXmlElement().Add(CreateRegisterInvoice(XmlinSchemaLbl));
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
    /// CreateRegisterInvoice.
    /// </summary>
    /// <param name="XmlniSchema">Text.</param>
    /// <returns>Return value of type XmlElement.</returns>
    procedure CreateRegisterInvoice(XmlniSchema: Text): XmlElement
    var
        SigningMgt: Codeunit "BET Signing Mgt";
        InvoiceEl: XmlElement;
        SupplyDateOrPeriodEl: XmlElement;
        PayMethodsEl: XmlElement;
        PayMethodEl: XmlElement;
        SellerEl: XmlElement;
        BuyerEl: XmlElement;
        ItemsEl: XmlElement;
        IEl: XmlElement;
        SameTaxes: XmlElement;
        SameTax: XmlElement;
        IIC: Text;
        IICSignature: Text;
        IICText: Text;
    begin
        InvoiceEl := XmlElement.Create('Invoice', XmlinSchemaLbl);
        SupplyDateOrPeriodEl := XmlElement.Create('SupplyDateOrPeriod', XmlinSchemaLbl);
        PayMethodsEl := XmlElement.Create('PayMethods', XmlinSchemaLbl);
        PayMethodEl := XmlElement.Create('PayMethod', XmlinSchemaLbl);
        SellerEl := XmlElement.Create('Seller', XmlinSchemaLbl);
        BuyerEl := XmlElement.Create('Buyer', XmlinSchemaLbl);
        ItemsEl := XmlElement.Create('Items', XmlinSchemaLbl);
        IEl := XmlElement.Create('I', XmlinSchemaLbl);
        SameTaxes := XmlElement.Create('SameTaxes', XmlinSchemaLbl);
        SameTax := XmlElement.Create('SameTax', XmlinSchemaLbl);

        IICText := FiscTypeHelper.AdjustIIC('L00000000A', FiscTypeHelper.GetCurrentUTCDateTime(), '1/2026', 'aa000aa000', 'bb000bb000', 'cc000cc000', '100.00');
        SigningMgt.ComputeIICorWTNICSignature(IICText, 'TEST_CERTIFICATE', IIC, IICSignature);

        InvoiceEl.SetAttribute('TypeOfInv', 'NONCASH');
        InvoiceEl.SetAttribute('IsSimplifiedInv', 'false');
        InvoiceEl.SetAttribute('IssueDateTime', FiscTypeHelper.GetCurrentUTCDateTime());
        InvoiceEl.SetAttribute('InvNum', '1/2026');
        InvoiceEl.SetAttribute('InvOrdNum', '1');
        InvoiceEl.SetAttribute('TCRCode', 'bb000bb000');
        InvoiceEl.SetAttribute('IsIssuerInVAT', 'true');
        InvoiceEl.SetAttribute('TotPriceWoVAT', '83.33');
        InvoiceEl.SetAttribute('TotVATAmt', '16.67');
        InvoiceEl.SetAttribute('TotPrice', '100.00');
        InvoiceEl.SetAttribute('OperatorCode', 'dd000dd000');
        InvoiceEl.SetAttribute('BusinUnitCode', 'aa000aa000');
        InvoiceEl.SetAttribute('SoftCode', 'cc000cc000');
        InvoiceEl.SetAttribute('IIC', IIC);
        InvoiceEl.SetAttribute('IICSignature', IICSignature);
        InvoiceEl.SetAttribute('IsReverseCharge', 'false');
        InvoiceEl.SetAttribute('PayDeadline', '2026-09-15');
        InvoiceEl.SetAttribute('IsEinvoice', 'true');

        SupplyDateOrPeriodEl.SetAttribute('Start', '2026-08-31');
        SupplyDateOrPeriodEl.SetAttribute('End', '2026-08-31');
        SupplyDateOrPeriodEl.Add(XmlText.Create(''));

        SellerEl.SetAttribute('IDType', 'NUIS');
        SellerEl.SetAttribute('IDNum', 'L00000000A');
        SellerEl.SetAttribute('Name', 'Demo Seller Ltd.');
        SellerEl.SetAttribute('Address', 'Demo Seller Address');
        SellerEl.SetAttribute('Town', 'Tirane');
        SellerEl.SetAttribute('Country', 'ALB');
        SellerEl.Add(XmlText.Create(''));

        BuyerEl.SetAttribute('IDType', 'NUIS');
        BuyerEl.SetAttribute('IDNum', 'K00000000A');
        BuyerEl.SetAttribute('Name', 'Demo Buyer Ltd.');
        BuyerEl.SetAttribute('Address', 'Demo Buyer Address');
        BuyerEl.SetAttribute('Town', 'Durres');
        BuyerEl.SetAttribute('Country', 'ALB');
        BuyerEl.Add(XmlText.Create(''));

        PayMethodEl.SetAttribute('Type', 'ACCOUNT');
        PayMethodEl.SetAttribute('Amt', '100.00');
        PayMethodEl.Add(XmlText.Create(''));
        PayMethodsEl.Add(PayMethodEl);

        IEl.SetAttribute('N', 'DEMO SERVICE');
        IEl.SetAttribute('C', 'DEMO001');
        IEl.SetAttribute('U', 'PCS');
        IEl.SetAttribute('Q', '1.00');
        IEl.SetAttribute('UPB', '83.33');
        IEl.SetAttribute('UPA', '100.00');
        IEl.SetAttribute('PB', '83.33');
        IEl.SetAttribute('VR', '20.00');
        IEl.SetAttribute('VA', '16.67');
        IEl.SetAttribute('PA', '100.00');
        IEl.Add(XmlText.Create(''));
        ItemsEl.Add(IEl);

        SameTax.SetAttribute('NumOfItems', '1');
        SameTax.SetAttribute('PriceBefVAT', '83.33');
        SameTax.SetAttribute('VATRate', '20.00');
        SameTax.SetAttribute('VATAmt', '16.67');
        SameTax.Add(XmlText.Create(''));
        SameTaxes.Add(SameTax);

        InvoiceEl.Add(SupplyDateOrPeriodEl);
        InvoiceEl.Add(PayMethodsEl);
        InvoiceEl.Add(SellerEl);
        InvoiceEl.Add(BuyerEl);
        InvoiceEl.Add(ItemsEl);
        InvoiceEl.Add(SameTaxes);

        exit(InvoiceEl);
    end;
}