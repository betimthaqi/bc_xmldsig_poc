/// <summary>
/// Codeunit BET Signing Mgt (ID 50000).
/// </summary>
codeunit 50000 "BET Signing Mgt"
{
    /// <summary>
    /// GenerateIIC.
    /// </summary>
    /// <param name="IICText">Text.</param>
    /// <param name="CertificateCode">Code[20].</param>
    /// <param name="IICorWTNIC">VAR Text.</param>
    /// <param name="IICorWTINCSignature">VAR Text.</param>
    procedure ComputeIICorWTNICSignature(IICText: Text; CertificateCode: Code[20]; var IICorWTNIC: Text; var IICorWTINCSignature: Text)
    var
        IsolatedCertificate: Record "Isolated Certificate";
        CryptographyManagement: Codeunit "Cryptography Management";
        CertificateManagement: Codeunit "Certificate Management";
        SignatureKey: Codeunit "Signature Key";
        FISCTypeHelper: Codeunit "BET FISC Type Helper";
        TempBlob: Codeunit "Temp Blob";
        SignatureOutStream: OutStream;
        SignatureInStream: InStream;
    begin
        if IsolatedCertificate.Get(CertificateCode) then
            CertificateManagement.GetCertPrivateKey(IsolatedCertificate, SignatureKey);

        TempBlob.CreateOutStream(SignatureOutStream);
        TempBlob.CreateInStream(SignatureInStream);
        CryptographyManagement.SignData(IICText, SignatureKey, Enum::"Hash Algorithm"::SHA256, SignatureOutStream);

        IICorWTINCSignature := FISCTypeHelper.StreamToHex(SignatureInStream);
        IICorWTNIC := CryptographyManagement.GenerateHash(IICorWTINCSignature, 0);
    end;

    /// <summary>
    /// GenerateSigning.
    /// </summary>
    /// <param name="XMTToSign">XmlDocument.</param>
    /// <param name="CertificateCode">Code[20].</param>
    /// <param name="XmlnSchema">Text.</param>
    /// <returns>Return variable Signature of type XmlElement.</returns>
    procedure GenerateSigning(XMTToSign: XmlDocument; CertificateCode: Code[20]; XmlnSchema: Text) XMLSignature: XmlElement
    var
        IsolatedCertificate: Record "Isolated Certificate";
        CertificateManagement: Codeunit "Certificate Management";
        SignatureKey: Codeunit "Signature Key";
        SignedXmlCodeunit: Codeunit SignedXml;
        X509DataEl: XmlElement;
        X509CertificateEl: XmlElement;
        XmlElemKeyInfo: XmlElement;
        CertBase64: Text;
    begin
        if IsolatedCertificate.Get(CertificateCode) then begin
            CertBase64 := CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate);
            CertificateManagement.GetCertPrivateKey(IsolatedCertificate, SignatureKey);
        end;

        SignedXmlCodeunit.InitializeSignedXml(XMTToSign);

        SignedXmlCodeunit.InitializeReference('#Request');
        SignedXmlCodeunit.AddXmlDsigEnvelopedSignatureTransform();
        SignedXmlCodeunit.AddXmlDsigExcC14NTransformToReference();
        SignedXmlCodeunit.AddReferenceToSignedXML();

        SignedXmlCodeunit.SetCanonicalizationMethod(SignedXmlCodeunit.GetXmlDsigExcC14NTransformUrl());
        SignedXmlCodeunit.SetSignatureMethod(SignedXmlCodeunit.GetXmlDsigRSASHA256Url());

        SignedXmlCodeunit.InitializeKeyInfo();
        XmlElemKeyInfo := XmlElement.Create('KeyInfo', XmlnSchema);
        X509DataEl := XmlElement.Create('X509Data', XmlnSchema);
        X509CertificateEl := XmlElement.Create('X509Certificate', XmlnSchema);
        X509CertificateEl.Add(XmlText.Create(CertBase64));
        X509DataEl.Add(X509CertificateEl);
        XmlElemKeyInfo.Add(X509DataEl);
        SignedXmlCodeunit.AddClause(X509DataEl);

        SignedXmlCodeunit.SetSigningKey(SignatureKey);
        SignedXmlCodeunit.ComputeSignature();

        XMLSignature := SignedXmlCodeunit.GetXml();
    end;
}