/// <summary>
/// Codeunit BET FISC Type Helper (ID 50003).
/// </summary>
codeunit 50003 "BET FISC Type Helper"
{
    /// <summary>
    /// StreamToHex.
    /// </summary>
    /// <param name="ValueInStream">InStream.</param>
    /// <returns>Return variable ReturnValue of type Text.</returns>
    procedure StreamToHex(ValueInStream: InStream) ReturnValue: Text
    var
        TypeHelper: Codeunit "Type Helper";
        SingleByte: Byte;
        HexValue: Text;
    begin
        while not ValueInStream.EOS do begin
            ValueInStream.Read(SingleByte, 1);
            if StrLen(TypeHelper.IntToHex(BinaryToInt(ByteToBinary(SingleByte, 8)))) = 1 then
                HexValue += '0' + TypeHelper.IntToHex(BinaryToInt(ByteToBinary(SingleByte, 8)))
            else
                HexValue += TypeHelper.IntToHex(BinaryToInt(ByteToBinary(SingleByte, 8)));
        end;

        ReturnValue := HexValue;
    end;

    /// <summary>
    /// ByteToBinary.
    /// </summary>
    /// <param name="Value">Byte.</param>
    /// <param name="ByteLenght">Integer.</param>
    /// <returns>Return variable ReturnValue of type Text.</returns>
    procedure ByteToBinary(Value: Byte; ByteLenght: Integer) ReturnValue: Text;
    var
        BinaryValue: Text;
    begin
        BinaryValue := IntToBinary(Value);
        BinaryValue := IncreaseStringLength(BinaryValue, ByteLenght);
        ReturnValue := BinaryValue;
    end;

    local procedure IntToBinary(Value: integer) ReturnValue: text;
    begin
        while Value >= 1 do begin
            ReturnValue := Format(Value mod 2) + ReturnValue;
            Value := Value div 2;
        end;
    end;

    local procedure BinaryToInt(Value: Text) ReturnValue: Integer;
    var
        Multiplier: BigInteger;
        IntValue: Integer;
        i: Integer;
    begin
        Multiplier := 1;
        for i := StrLen(Value) downto 1 do begin
            Evaluate(IntValue, CopyStr(Value, i, 1));
            ReturnValue += IntValue * Multiplier;
            Multiplier *= 2;
        end;
    end;

    local procedure IncreaseStringLength(Value: Text; ToLength: Integer) ReturnValue: Text;
    var
        ExtraLength: Integer;
        ExtraText: Text;
    begin
        ExtraLength := ToLength - StrLen(Value);

        if ExtraLength < 0 then
            exit;

        ExtraText := PadStr(ExtraText, ExtraLength, '0');
        ReturnValue := ExtraText + Value;
    end;

    /// <summary>
    /// GetCurrentUTCDateTime.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetCurrentUTCDateTime() UTCWithTimeZone: Text
    var
        CurrentDateTime: DateTime;
    begin
        CurrentDateTime := CurrentDateTime();

        AdjustCurrentUTCDateTime(CurrentDateTime, UTCWithTimeZone);
    end;

    /// <summary>
    /// GetCurrentUTCDateTime.
    /// /// </summary>
    /// <param name="CurrentDateTime">DateTime.</param>
    /// <returns>Return value of type Text.</returns>
    procedure GetCurrentUTCDateTime(CurrentDateTime: DateTime) UTCWithTimeZone: Text
    begin
        AdjustCurrentUTCDateTime(CurrentDateTime, UTCWithTimeZone);
    end;

    internal procedure AdjustCurrentUTCDateTime(CurrentDateTime: DateTime; var UTCWithTimeZone: Text)
    var
        TimeZone: Codeunit "Time Zone";
        UTCISO8601, OffsetHours, DateXml, TimeXml : Text;
        Date: Date;
        Time: Time;
        TimeZoneOffset: Duration;
        OffsetTime: Time;
    begin
        Date := DT2Date(CurrentDateTime);
        Time := DT2Time(CurrentDateTime);
        DateXml := Format(Date, 0, 9);
        TimeXml := Format(Time, 0, '<Hours24,2><Filler Character,0>:<Minutes,2><Filler Character,0>:<Seconds,2><Filler Character,0>');

        UTCISO8601 := DateXml + 'T' + TimeXml;

        TimeZoneOffset := TimeZone.GetTimezoneOffset(CurrentDateTime);

        if StrPos(Format(TimeZoneOffset), '-') > 0 then begin
            OffsetTime := 000000T - TimeZoneOffset;
            OffsetHours := Format(OffsetTime, 0, '-<Hours24,2><Filler Character,0>:<Minutes,2>');
        end
        else begin
            OffsetTime := 000000T + TimeZoneOffset;
            OffsetHours := Format(OffsetTime, 0, '+<Hours24,2><Filler Character,0>:<Minutes,2>');
        end;

        UTCWithTimeZone := UTCISO8601 + OffsetHours;
    end;

    /// <summary>
    /// CreateUUID.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CreateUUID(): Text
    var
        UUID: Text;
    begin
        UUID := Format(CreateGuid());
        UUID := DelChr(UUID, '=', '{}');
        UUID := UUID.ToLower();
        exit(UUID);
    end;

    /// <summary>
    /// CreateIIC.
    /// </summary>
    /// <param name="IssuerNuis">Text.</param>
    /// <param name="DateTimeCreated">Text.</param>
    /// <param name="InvoiceNumber">Text.</param>
    /// <param name="BusiUnitCode">Text.</param>
    /// <param name="TCRCode">Text.</param>
    /// <param name="SoftCode">Text.</param>
    /// <param name="TotalPrice">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure AdjustIIC(IssuerNuis: Text; DateTimeCreated: Text; InvoiceNumber: Text; BusiUnitCode: Text; TCRCode: Text; SoftCode: Text; TotalPrice: Text): Text
    begin
        exit(IssuerNuis + '|' + DateTimeCreated + '|' + InvoiceNumber + '|' + BusiUnitCode + '|' + TCRCode + '|' + SoftCode + '|' + TotalPrice);
    end;

    /// <summary>
    /// CreateIIC.
    /// </summary>
    /// <param name="IssuerNuis">Text.</param>
    /// <param name="DateTimeCreated">Text.</param>
    /// <param name="WtnNumber">Text.</param>
    /// <param name="BusiUnitCode">Text.</param>
    /// <param name="SoftCode">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure AdjustWTNIC(IssuerNuis: Text; DateTimeCreated: Text; WtnNumber: Text; BusiUnitCode: Text; SoftCode: Text): Text
    begin
        exit(IssuerNuis + '|' + DateTimeCreated + '|' + WtnNumber + '|' + BusiUnitCode + '|' + SoftCode);
    end;
}