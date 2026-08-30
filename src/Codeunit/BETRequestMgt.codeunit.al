/// <summary>
/// Codeunit BET BET SDA API Mgt (ID 50001).
/// </summary>
codeunit 50001 "BET Request Mgt"
{
    //Generic codeunit to send http requests
    /// <summary>
    /// SendRequest.
    /// </summary>
    /// <param name="RequestMethod">enum "Http Request Type".</param>
    /// <param name="requestUri">Text.</param>
    /// <returns>Return value of type text.</returns>
    procedure SendRequest(RequestMethod: Enum "Http Request Type"; requestUri: Text): Text
    var
        DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper";
        DictionaryWrapperContentHeaders: Codeunit "Dictionary Wrapper";
        ContentType: Text;
    begin
        exit(SendRequest('', RequestMethod, requestUri, ContentType, 0, DictionaryWrapperContentHeaders, DictionaryWrapperDefaultHeaders));
    end;

    /// <summary>
    /// SendRequest.
    /// </summary>
    /// <param name="ContentToSendVariant">Variant.</param>
    /// <param name="RequestMethod">enum "Http Request Type".</param>
    /// <param name="requestUri">Text.</param>
    /// <param name="ContentType">Text.</param>
    /// <returns>Return value of type text.</returns>
    procedure SendRequest(ContentToSendVariant: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text): text
    var
        DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper";
        DictionaryWrapperContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        exit(SendRequest(ContentToSendVariant, RequestMethod, requestUri, ContentType, 0, DictionaryWrapperContentHeaders, DictionaryWrapperDefaultHeaders));
    end;

    /// <summary>
    /// SendRequest.
    /// </summary>
    /// <param name="ContentToSendVariant">Variant.</param>
    /// <param name="RequestMethod">enum "Http Request Type".</param>
    /// <param name="requestUri">Text.</param>
    /// <param name="ContentType">Text.</param>
    /// <param name="DictionaryWrapperDefaultHeaders">Codeunit "Dictionary Wrapper".</param>
    /// <returns>Return value of type text.</returns>
    procedure SendRequest(ContentToSendVariant: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text; DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper"): Text
    var
        DictionaryWrapperContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        exit(SendRequest(ContentToSendVariant, RequestMethod, requestUri, ContentType, 0, DictionaryWrapperContentHeaders, DictionaryWrapperDefaultHeaders));
    end;

    /// <summary>
    /// SendRequest.
    /// </summary>
    /// <param name="ContentToSendVariant">Variant.</param>
    /// <param name="RequestMethod">enum "Http Request Type".</param>
    /// <param name="requestUri">Text.</param>
    /// <param name="ContentType">Text.</param>
    /// <param name="HttpTimeout">integer.</param>
    /// <param name="DictionaryWrapperContentHeaders">Codeunit "Dictionary Wrapper".</param>
    /// <param name="DictionaryWrapperDefaultHeaders">Codeunit "Dictionary Wrapper".</param>
    /// <returns>Return value of type text.</returns>
    procedure SendRequest(ContentToSendVariant: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text; HttpTimeout: integer; DictionaryWrapperContentHeaders: Codeunit "Dictionary Wrapper"; DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper"): Text
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
        ErrorBodyContent: Text;
        TextContent: Text;
        InStreamContent: InStream;
        i: Integer;
        KeyVariant: Variant;
        ValueVariant: Variant;
        HasContent: Boolean;
    begin
        case true of
            ContentToSendVariant.IsText():
                begin
                    TextContent := ContentToSendVariant;
                    if TextContent <> '' then begin
                        HttpContent.WriteFrom(TextContent);
                        HasContent := true;
                    end;
                end;
            ContentToSendVariant.IsInStream():
                begin
                    InStreamContent := ContentToSendVariant;
                    HttpContent.WriteFrom(InStreamContent);
                    HasContent := true;
                end;
            else
                Error(UnsupportedContentToSendErr);
        end;

        if HasContent then
            HttpRequestMessage.Content := HttpContent;

        if ContentType <> '' then begin
            HttpContentHeaders.Clear();
            HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
            if HttpContentHeaders.Contains(ContentTypeKeyLbl) then
                HttpContentHeaders.Remove(ContentTypeKeyLbl);

            HttpContentHeaders.Add(ContentTypeKeyLbl, ContentType);
        end;

        for i := 0 to DictionaryWrapperContentHeaders.Count() do
            if DictionaryWrapperContentHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                HttpContentHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        HttpRequestMessage.SetRequestUri(requestUri);
        HttpRequestMessage.Method := Format(RequestMethod);

        for i := 0 to DictionaryWrapperDefaultHeaders.Count() do
            if DictionaryWrapperDefaultHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                HttpClient.DefaultRequestHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        if HttpTimeout <> 0 then
            HttpClient.Timeout(HttpTimeout);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content().ReadAs(ErrorBodyContent);
            Error(RequestErr, HttpResponseMessage.HttpStatusCode(), ErrorBodyContent);
        end;

        exit(ResponseText);
    end;

    /// <summary>
    /// SendAPIRequest.
    /// </summary>
    /// <param name="ContentToSend">Text.</param>
    /// <param name="ContentType">Text.</param>
    /// <param name="FiscNamespaceUriLbl">Text.</param>
    /// <param name="FiscActionUriLbl">Text.</param>
    /// <param name="DictionaryWrapperDefaultHeaders">Codeunit "Dictionary Wrapper".</param>
    /// <returns>Return value of type Text.</returns>
    procedure SendAPIRequest(ContentToSend: Text; ContentType: Text; FiscNamespaceUriLbl: Text; FiscActionUriLbl: Text; DictionaryWrapperDefaultHeaders: Codeunit "Dictionary Wrapper"): Text
    var
        RequestMgt: Codeunit "BET Request Mgt";
    begin
        exit(RequestMgt.SendRequest(ContentToSend, Enum::"Http Request Type"::POST, FiscNamespaceUriLbl + FiscActionUriLbl, ContentType, DictionaryWrapperDefaultHeaders));
    end;

    var
        RequestErr: Label 'Request failed with HTTP Code:: %1 Request Body:: %2', Comment = '%1 = HttpCode, %2 = RequestBody';
        UnsupportedContentToSendErr: Label 'Unsuportted content to send.';
        ContentTypeKeyLbl: Label 'Content-Type', Locked = true;
}