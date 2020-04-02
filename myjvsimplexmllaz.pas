{
  Developed By: Ednaldo Luiz dos Santos Moreira
  Email: ednaldo.moreira.dev@gmail.com
  Twitter: @ed_moreira
}
unit MyJvSimpleXMLLaz;

{$mode delphi}

interface

uses
  Classes, SysUtils, Windows, DOM, XMLWrite, XMLRead;

type
  TMyJvSimpleXMLElem=class;
  TMyJvSimpleXMLProp=class;

  { TMyJvSimpleXMLElems }

  TMyJvSimpleXMLElems=class
    FListItems:TStringList;
    FParent: TMyJvSimpleXMLElem;
  private
    function Get_Count: Integer;
    function Get_Item(const Index: Integer): TMyJvSimpleXMLElem;
    function Get_ItemNamed(const Name: String): TMyJvSimpleXMLElem;
  public
    property Item[const Index:Integer]:TMyJvSimpleXMLElem read Get_Item;default;
    property ItemNamed[const Name:String]:TMyJvSimpleXMLElem read Get_ItemNamed;
    function Add(const Name:string):TMyJvSimpleXMLElem;overload;
    function Add(const Name:string; const AValue:string):TMyJvSimpleXMLElem;overload;
    function Add(const Name:string; const AValue:Int64):TMyJvSimpleXMLElem;overload;
    function Add(const Elemento:TMyJvSimpleXMLElem):TMyJvSimpleXMLElem;overload;
    function Insert(const Name:string;const Index:Integer):TMyJvSimpleXMLElem;overload;
    function Insert(const Elemento:TMyJvSimpleXMLElem;const Index:Integer):TMyJvSimpleXMLElem;overload;
    function Delete(const Index:Integer):TMyJvSimpleXMLElem;overload;
    function Delete(const Name:string):TMyJvSimpleXMLElem;overload;
    function Move(const CurlIndex:Integer;const NewIndex:Integer):TMyJvSimpleXMLElem;
    constructor Create(AParent: TMyJvSimpleXMLElem);
  published
    property Count:Integer read Get_Count;
  end;

  { TMyJvSimpleXMLProps }

  TMyJvSimpleXMLProps=class
    FListItems:TStringList;
    FParent: TMyJvSimpleXMLElem;
  private
    xmlNode:TDOMNode;
    function Get_Count(): Integer;
    function Get_Item(const Index: Integer): TMyJvSimpleXMLProp;
    function Get_ItemNamed(const Name: String): TMyJvSimpleXMLProp;
  public
    property Item[const Index:Integer]:TMyJvSimpleXMLProp read Get_Item;default;
    property ItemNamed[const Name:String]:TMyJvSimpleXMLProp read Get_ItemNamed;
    function Add(const Name:string; const Value:string):TMyJvSimpleXMLProp;overload;
    function Add(const Name:string; const Value:Int64):TMyJvSimpleXMLProp;overload;
    constructor Create(AParent: TMyJvSimpleXMLElem);
  published
    property Count:Integer read Get_Count;
  end;

  { TMyJvSimpleXMLElem }

  TMyJvSimpleXMLElem=class
    FItems:TMyJvSimpleXMLElems;
    FProperties:TMyJvSimpleXMLProps;
    FName:String;
    FValue:String;
  private
    function Get_Items: TMyJvSimpleXMLElems;
    function Get_Name: String;
    function Get_Properties: TMyJvSimpleXMLProps;
    function Get_Value: String;
    procedure Set_Name(AValue: String);
    procedure Set_Value(AValue: String);
    function SaveToString():String;
  public
    Parent:TMyJvSimpleXMLElem;
    Posicao:Integer;
    constructor Create();
  published
    property Items:TMyJvSimpleXMLElems read Get_Items;
    property Properties:TMyJvSimpleXMLProps read Get_Properties;
    property Name:String read Get_Name write Set_Name;
    property Value:String read Get_Value write Set_Value;
  end;

  { TMyJvSimpleXMLProp }

  TMyJvSimpleXMLProp=class
    Parent:TMyJvSimpleXMLElem;
    Posicao:Integer;
    FName:String;
    FValue:String;
  private
    function Get_Name: String;
    function Get_Value: String;
    procedure Set_Name(AValue: String);
    procedure Set_Value(AValue: String);
  public
    constructor Create();
  published
    property Name:String read Get_Name write Set_Name;
    property Value:String read Get_Value write Set_Value;
  end;

  { TMyJvSimpleXML }

  TMyJvSimpleXML=class
  private
    FRoot: TMyJvSimpleXMLElem;
    function Get_Root: TMyJvSimpleXMLElem;
    function SaveToDOM():TXMLDocument;
    procedure LoadFromDOM(xmlDoc:TXMLDocument);
  public
    procedure LoadFromString(const Value:string);
    procedure LoadFromFile(FileName:TFilename);
    procedure LoadFromStream(const Stream:TStream);
    function SaveToString():string;
    procedure SaveToStream(const Stream:TStream);
    procedure SaveToFile(FileName:TFilename);
    constructor Create;
  published
    property Root:TMyJvSimpleXMLElem read Get_Root;
  end;

implementation

{ TMyJvSimpleXMLProp }

function TMyJvSimpleXMLProp.Get_Name: String;
begin
  Result := FName;
end;

function TMyJvSimpleXMLProp.Get_Value: String;
begin
  Result := FValue;
end;

procedure TMyJvSimpleXMLProp.Set_Name(AValue: String);
begin
  FName:=AValue;
  if Parent <> Nil then
    Parent.Properties.FListItems[Self.Posicao]:=AValue;
end;

procedure TMyJvSimpleXMLProp.Set_Value(AValue: String);
begin
  FValue:=AValue;
end;

constructor TMyJvSimpleXMLProp.Create();
begin
  Parent:=Nil;
end;

{ TMyJvSimpleXMLElems }

function TMyJvSimpleXMLElems.Get_Count: Integer;
begin
  Result:=FlistItems.Count;
end;

function TMyJvSimpleXMLElems.Get_Item(const Index: Integer): TMyJvSimpleXMLElem;
begin
  Result:=TMyJvSimpleXMLElem(FListItems.Objects[Index]);
end;

function TMyJvSimpleXMLElems.Get_ItemNamed(const Name: String
  ): TMyJvSimpleXMLElem;
var
  Indice:Integer;
begin
  Indice:=FListItems.IndexOf(Name);
  if Indice > -1 then
    Result:=TMyJvSimpleXMLElem(FListItems.Objects[Indice])
  else
    Result := Nil;
end;

function TMyJvSimpleXMLElems.Delete(const Index: Integer): TMyJvSimpleXMLElem;
var
  i:integer;
begin
  Result:=TMyJvSimpleXMLElem(FListItems.Objects[Index]);
  FListItems.Delete(Index);

  for i:=Index to FParent.Items.Count - 1 do
    FParent.Items[i].Posicao := i;

end;

function TMyJvSimpleXMLElems.Delete(const Name: string): TMyJvSimpleXMLElem;
var
  Indice:Integer;
begin
  Indice:=FListItems.IndexOf(Name);
  if Indice > -1 then
    Result := Delete(Indice);
end;

function TMyJvSimpleXMLElems.Move(const CurlIndex: Integer;
  const NewIndex: Integer): TMyJvSimpleXMLElem;
var
  elemento:TMyJvSimpleXMLElem;
  Indice, MenorIndice, MaiorIndice, i:Integer;
begin
  if NewIndex > CurlIndex then
  begin
    Indice:=NewIndex - 1;
    MaiorIndice:=NewIndex;
    MenorIndice:=CurlIndex;
  end
  else
  begin
    Indice:=NewIndex;
    MaiorIndice:=CurlIndex;
    MenorIndice:=NewIndex;
  end;

  elemento:=TMyJvSimpleXMLElem(FListItems.Objects[CurlIndex]);

  FListItems.Delete(CurlIndex);

  FListItems.InsertObject(Indice, elemento.Name, elemento);

  for i:= MenorIndice to MaiorIndice do
    FParent.Items[i].Posicao := i;

  Result := elemento;
end;

constructor TMyJvSimpleXMLElems.Create(AParent: TMyJvSimpleXMLElem);
begin
  FListItems:=TStringList.Create;
  FParent:=AParent;
end;

function TMyJvSimpleXMLElems.Add(const Name: string): TMyJvSimpleXMLElem;
var
  elemento:TMyJvSimpleXMLElem;
begin
  elemento:=TMyJvSimpleXMLElem.Create;
  elemento.Name:=Name;
  FListItems.AddObject(Name, elemento);
  elemento.Parent:=FParent;
  elemento.Posicao:=FListItems.Count - 1;

  Result:=elemento;
end;

function TMyJvSimpleXMLElems.Add(const Name: string; const AValue: string
  ): TMyJvSimpleXMLElem;
begin
  Result:=Add(Name);
  Result.Value := AValue;
end;

function TMyJvSimpleXMLElems.Add(const Name: string; const AValue: Int64
  ): TMyJvSimpleXMLElem;
begin
  Result:=Add(Name);
  Result.Value := IntToStr(AValue);
end;

function TMyJvSimpleXMLElems.Add(const Elemento: TMyJvSimpleXMLElem
  ): TMyJvSimpleXMLElem;
begin

  FListItems.AddObject(Elemento.Name, Elemento);
  Elemento.Parent:=FParent;
  Elemento.Posicao:=FListItems.Count - 1;

  Result:=Elemento;
end;

function TMyJvSimpleXMLElems.Insert(const Name: string; const Index: Integer
  ): TMyJvSimpleXMLElem;
var
  elemento:TMyJvSimpleXMLElem;
  i:Integer;
begin
  elemento:=TMyJvSimpleXMLElem.Create;
  FListItems.InsertObject(Index, Name, elemento);
  elemento.Parent:=FParent;
  elemento.Posicao:=Index;
  for i:=Index +1 to FParent.Items.Count - 1 do
    FParent.Items[i].Posicao := i;

  Result := elemento;
end;

function TMyJvSimpleXMLElems.Insert(const Elemento: TMyJvSimpleXMLElem;
  const Index: Integer): TMyJvSimpleXMLElem;
var
  i:Integer;
begin
  FListItems.InsertObject(Index, Elemento.Name, elemento);
  Elemento.Parent:=FParent;
  Elemento.Posicao:=Index;
  for i:=Index +1 to FParent.Items.Count - 1 do
    FParent.Items[i].Posicao := i;

  Result := Elemento;
end;

{ TMyJvSimpleXMLElem }

function TMyJvSimpleXMLElem.Get_Items: TMyJvSimpleXMLElems;
begin
  Result := FItems;
end;

function TMyJvSimpleXMLElem.Get_Name: String;
begin
  Result := FName;
end;

function TMyJvSimpleXMLElem.Get_Properties: TMyJvSimpleXMLProps;
begin
  Result := FProperties;
end;

function TMyJvSimpleXMLElem.Get_Value: String;
begin
  Result := FValue;
end;

procedure TMyJvSimpleXMLElem.Set_Name(AValue: String);
begin
  FName:=AValue;
  if Parent <> Nil then
    Parent.Items.FListItems[Self.Posicao]:=AValue;
end;

procedure TMyJvSimpleXMLElem.Set_Value(AValue: String);
begin
  FValue:=AValue;
end;

function TMyJvSimpleXMLElem.SaveToString(): String;
begin
  if FItems.Count > 0 then
    Result := ''
  else
    Result := FValue;

end;

constructor TMyJvSimpleXMLElem.Create();
begin
  FItems:=TMyJvSimpleXMLElems.Create(Self);
  FProperties:=TMyJvSimpleXMLProps.Create(Self);
  Parent:=Nil;
end;

{ TMyJvSimpleXMLProps }

function TMyJvSimpleXMLProps.Get_Count(): Integer;
begin
  FlistItems.Count;
end;

function TMyJvSimpleXMLProps.Get_Item(const Index: Integer): TMyJvSimpleXMLProp;
begin
  Result:=TMyJvSimpleXMLProp(FListItems.Objects[Index]);
end;

function TMyJvSimpleXMLProps.Get_ItemNamed(const Name: String
  ): TMyJvSimpleXMLProp;
var
  Indice:Integer;
begin
  Indice:=FListItems.IndexOf(Name);
  if Indice > -1 then
    Result:=TMyJvSimpleXMLProp(FListItems.Objects[Indice])
  else
    Result := Nil;
end;

function TMyJvSimpleXMLProps.Add(const Name: string; const Value: string
  ): TMyJvSimpleXMLProp;
var
  elemento:TMyJvSimpleXMLProp;
begin
  elemento:=TMyJvSimpleXMLProp.Create;
  elemento.Name:=Name;
  elemento.Value:=Value;
  elemento.Parent:=FParent;
  FListItems.AddObject(Name, elemento);
  elemento.Posicao:=FListItems.Count - 1;
  Result:=elemento;
end;

function TMyJvSimpleXMLProps.Add(const Name: string; const Value: Int64
  ): TMyJvSimpleXMLProp;
begin
  Result:=Add(Name, IntToStr(Value));
end;

constructor TMyJvSimpleXMLProps.Create(AParent: TMyJvSimpleXMLElem);
begin
  FListItems:=TStringList.Create;
  FParent:=AParent;
end;


{ TMyJvSimpleXML }

function TMyJvSimpleXML.Get_Root: TMyJvSimpleXMLElem;
begin
  Result := Froot;
end;

function TMyJvSimpleXML.SaveToDOM(): TXMLDocument;
var
  xmlDoc:TXMLDocument;
  RootNode: TDOMNode;
  procedure CreateMyNode(ADOMParentNode:TDOMElement; MyJvSimpleXMLElem:TMyJvSimpleXMLElem);
  var
    ANewNode: TDOMNode;
    i:Integer;
  begin
    if MyJvSimpleXMLElem.Items.Count = 0 then
    begin
      ANewNode := xmlDoc.CreateTextNode(MyJvSimpleXMLElem.Value);
      ADOMParentNode.AppendChild(ANewNode);
    end;

    for i:=0 to MyJvSimpleXMLElem.Properties.Count - 1 do
      ADOMParentNode.SetAttribute(MyJvSimpleXMLElem.Properties[i].Name, MyJvSimpleXMLElem.Properties[i].Value);

    for i:=0 to MyJvSimpleXMLElem.Items.Count - 1 do
    begin

      ANewNode := xmlDoc.CreateElement(MyJvSimpleXMLElem.Items[i].Name);
      ADOMParentNode.AppendChild(ANewNode);
      CreateMyNode(TDOMElement(ANewNode), MyJvSimpleXMLElem.Items[i]);
    end;
  end;
begin
  xmlDoc := TXMLDocument.Create;
  RootNode := xmlDoc.CreateElement(FRoot.Name);
  xmlDoc.Appendchild(RootNode);

  CreateMyNode(xmlDoc.DocumentElement, FRoot);
  Result := xmlDoc;
end;

procedure TMyJvSimpleXML.LoadFromDOM(xmlDoc: TXMLDocument);
  procedure CreateMyNode(ADOMNode:TDOMElement; MyJvSimpleXMLElem:TMyJvSimpleXMLElem);
  var
    i:Integer;
  begin
    MyJvSimpleXMLElem.Name:=ADOMNode.NodeName;

    if not ADOMNode.HasChildNodes then
      MyJvSimpleXMLElem.Value:=ADOMNode.NodeValue
    else if ADOMNode.ChildNodes[0].NodeName='#text' then
      MyJvSimpleXMLElem.Value:=ADOMNode.ChildNodes[0].NodeValue;

    if ADOMNode.Attributes <> Nil then
      for i:=0 to ADOMNode.Attributes.Length - 1 do
        MyJvSimpleXMLElem.Properties.Add(ADOMNode.Attributes[i].NodeName, ADOMNode.Attributes[i].NodeValue);

    if ADOMNode.HasChildNodes and (ADOMNode.ChildNodes[0].NodeName <> '#text') then
      for i:=0 to ADOMNode.ChildNodes.Length - 1 do
        CreateMyNode(TDOMElement(ADOMNode.ChildNodes[i]), MyJvSimpleXMLElem.Items.Add(ADOMNode.ChildNodes[i].NodeName));

  end;
begin
  CreateMyNode(xmlDoc.DocumentElement, FRoot);
end;

procedure TMyJvSimpleXML.LoadFromString(const Value: string);
var
  xmlDoc:TXMLDocument;
begin
  xmlDoc:=TXMLDocument.Create;
  ReadXMLFile(xmlDoc, Value);
  LoadFromDOM(xmlDoc);
end;

procedure TMyJvSimpleXML.LoadFromFile(FileName: TFilename);
var
  xmlDoc:TXMLDocument;
begin
  xmlDoc:=TXMLDocument.Create;
  ReadXMLFile(xmlDoc, FileName);
  LoadFromDOM(xmlDoc);
end;

procedure TMyJvSimpleXML.LoadFromStream(const Stream: TStream);
var
  xmlDoc:TXMLDocument;
begin
  xmlDoc:=TXMLDocument.Create;
  ReadXMLFile(xmlDoc, Stream);
  LoadFromDOM(xmlDoc);
end;

function TMyJvSimpleXML.SaveToString(): string;
var
  xmlDoc:TXMLDocument;
  XMLString:TStringStream;
begin
  xmlDoc:=SaveToDOM();
  XMLString:=TStringStream.Create('');
  XMLString.Position:=0;
  WriteXML(xmlDoc, XMLString);

  Result := XMLString.DataString;
  XMLString.Free;
end;

procedure TMyJvSimpleXML.SaveToStream(const Stream: TStream);
var
  xmlDoc:TXMLDocument;
begin
  xmlDoc:=SaveToDOM();
  WriteXML(xmlDoc, Stream);
end;

procedure TMyJvSimpleXML.SaveToFile(FileName: TFilename);
var
  xmlDoc:TXMLDocument;
begin
  xmlDoc:=SaveToDOM();
  WriteXML(xmlDoc, FileName);
end;

constructor TMyJvSimpleXML.Create;
begin
  FRoot:=TMyJvSimpleXMLElem.Create;
  FRoot.Name:='';
end;

end.

