unit SynHighlighterText;

{$I SynEdit.inc}

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  SynEditHighlighter, SynEditTypes;

type
  TtkTokenKind = (tkNull, tkUnknown);
  TProcTableProc = procedure of Object;

type
  TSynTextSyn = class(TSynCustomHighLighter)
  private
    fSpaceAttri: TSynHighlighterAttributes;
    fTokenID: TtkTokenKind;
    Run: LongInt;
    fTokenPos: Integer;
    fLine: PChar;
    fLineNumber : Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    procedure MakeMethodTables;
    procedure NullProc;
    procedure UnknownProc;
  public
    class function GetLanguageName: string; override;                           //gp 2000-01-20
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(const Value: String; LineNumber:Integer); override;
    function GetToken: String; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
  published
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
  end;

procedure Register;

implementation

uses
  SynEditStrConst;

procedure Register;
begin
  RegisterComponents(SYNS_HighlightersPage, [TSynTextSyn]);
end;

constructor TSynTextSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace, SYNS_AttrSpace);
  AddAttribute(fSpaceAttri);
  SetAttributesOnChange(DefHighlightChange);
  MakeMethodTables;
end; { Create }

destructor TSynTextSyn.Destroy;
begin
  inherited Destroy;
end; { Destroy }

procedure TSynTextSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := NullProc;
    else
      fProcTable[I] := UnknownProc;
    end;
end;

procedure TSynTextSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TSynTextSyn.SetLine(const Value: String; LineNumber:Integer);
begin
  fLine := PChar(Value);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TSynTextSyn.UnknownProc;
begin
  Run:=Length(fLine);
  fTokenID := tkUnKnown;
end;

procedure TSynTextSyn.Next;
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
end;

class function TSynTextSyn.GetLanguageName: string;                           //gp 2000-01-20
begin
  Result := 'Text files';
end;

function TSynTextSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  result:=fSpaceAttri;
end;

function TSynTextSyn.GetTokenKind: integer;
begin
  Result := ord(tkUnKnown);
end;

function TSynTextSyn.GetTokenPos: Integer;
begin
  Result := 0;
end;

function TSynTextSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;
end;

(*function TSynTextSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end; *)

function TSynTextSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Length(fLine);
  SetString(Result, FLine, Len);
end;

function TSynTextSyn.GetTokenID: TtkTokenKind;
begin
  Result := tkUnKnown;
end;

function TSynTextSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  Result := fSpaceAttri;
end;

(*procedure TSynTextSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;*)

//procedure TSynTextSyn.ExportNext;
//begin
//  Next;
//  if Assigned(Exporter) then
//    with TmwCustomExport(Exporter) do begin
//        FormatToken(GetToken, fSpaceAttri, False, True);
//    end; //with
//end;

initialization
  RegisterPlaceableHighlighter(TSynTextSyn);                                  //gp 2000-01-20
end.
