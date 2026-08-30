/// <summary>
/// PageExtension Customer List Ext (ID 50000) extends Record Customer List.
/// </summary>
pageextension 50000 "BET Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action("BET SendTCRRequest")
            {
                ApplicationArea = All;
                Caption = 'Send TCR Request';
                ToolTip = 'SendTCRRequest';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Signature;

                trigger OnAction()
                var
                    PrepareReqMgt: Codeunit "BET Prepare TCR Request";
                begin
                    PrepareReqMgt.PrepareTCRRequest();
                end;
            }
        }
        addlast(processing)
        {
            action("BET SendInvoiceRequest")
            {
                ApplicationArea = All;
                Caption = 'Send Invoice Request';
                ToolTip = 'SendTCRRequest';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Signature;

                trigger OnAction()
                var
                    PrepareReqMgt: Codeunit "BET Prepare Invoice Request";
                begin
                    PrepareReqMgt.PrepareInvoiceRequest();
                end;
            }
        }
    }

    /// <summary>
    /// TextToTime.
    /// </summary>
    /// <param name="InputText">Text.</param>
    /// <param name="TimeVar">VAR Time.</param>
    /// <param name="UseLocalTime">Boolean.</param>
    /// <returns>Return variable IsConverted of type Boolean.</returns>
    procedure TextToTime(InputText: Text; var TimeVar: Time; UseLocalTime: Boolean) IsConverted: Boolean
    var
        CodeunitBt: Codeunit "Outlook Synch. Type Conv";
        DateTimeVar: DateTime;
    begin
        InputText := ConvertStr(InputText, ' ', ',');
        if StrPos(InputText, ',') = 0 then
            exit;

        IsConverted := Evaluate(TimeVar, CodeunitBt.GetSubStrByNo(2, InputText));

        if not IsConverted then
            exit;

        if UseLocalTime then
            DateTimeVar := CodeunitBt.UTC2LocalDT(CreateDateTime(Today, TimeVar))
        else
            DateTimeVar := CreateDateTime(Today, TimeVar);
        TimeVar := DT2Time(DateTimeVar);
    end;
}