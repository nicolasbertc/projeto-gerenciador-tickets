unit uTickets;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.Edit, FMX.ComboEdit, FMX.Calendar,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView;

type
  TTicket = record
    codigo, id_func : Integer;
    situacao : string;
    dt_entrega : TDateTime;
    //TDateField e TDateTime
  end;


  Tfrm_Tickets = class(TForm)
    FDConnection1: TFDConnection;
    TabControl1: TTabControl;
    Principal: TTabItem;
    Layout1: TLayout;
    Label1: TLabel;
    Button1: TButton;
    FDQTickets: TFDQuery;
    Layout2: TLayout;
    btnCadastrarTickets: TButton;
    btnDistribuirTickets: TButton;
    Button4: TButton;
    Cadastrar_Tickets: TTabItem;
    Distribuir_Tickets: TTabItem;
    Relatorio_Tickets: TTabItem;
    Layout3: TLayout;
    Label2: TLabel;
    Button5: TButton;
    Layout5: TLayout;
    edtQtdTickets: TEdit;
    Label3: TLabel;
    btnInserir: TButton;
    ComboEdit1: TComboEdit;
    Layout4: TLayout;
    Label4: TLabel;
    Button2: TButton;
    Layout6: TLayout;
    Layout7: TLayout;
    Label5: TLabel;
    Label6: TLabel;
    edtQtd: TEdit;
    FDQFuncionarios1: TFDQuery;
    btnDistribuir: TButton;
    Layout8: TLayout;
    Label7: TLabel;
    Button3: TButton;
    Calendar1: TCalendar;
    Layout9: TLayout;
    edtData: TEdit;
    ListViewTickets: TListView;
    Label8: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure btnCadastrarTicketsClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure inserirTicketsBanco(ticket : TTicket);
    procedure btnDistribuirTicketsClick(Sender: TObject);
    procedure preencherComboEdit;
    procedure btnDistribuirClick(Sender: TObject);
    procedure distribuirTickets;
    procedure Button4Click(Sender: TObject);
    procedure Calendar1DayClick(Sender: TObject);
    procedure PesquisarTicketsPorData(const DataSelecionada: string);
    procedure InserirItensNaListView;
    function FormatarData(const DataOriginal: string): string;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Tickets: Tfrm_Tickets;

implementation

{$R *.fmx}

uses uFuncionario, uPrincipal;

procedure Tfrm_Tickets.btnDistribuirClick(Sender: TObject);
begin
   distribuirTickets;
end;

procedure Tfrm_Tickets.btnDistribuirTicketsClick(Sender: TObject);
begin
  ComboEdit1.Text := '';
  edtQtd.Text := '';
  TabControl1.TabIndex := 2;
  PreencherComboEdit;
end;

procedure Tfrm_Tickets.btnInserirClick(Sender: TObject);
var vTickets : TTicket;
    i, qtd : Integer;
begin
  qtd := StrToInt(edtQtdTickets.Text);
  for i := 1 to qtd do
  begin
    vTickets.situacao := 'A';
    inserirTicketsBanco(vTickets);
  end;

  ShowMessage('Ticket adicionado com sucesso!');
  TabControl1.TabIndex := 0;

end;

procedure Tfrm_Tickets.Button1Click(Sender: TObject);
begin
  frm_Tickets.Close;
  frm_Principal.Show;
end;

procedure Tfrm_Tickets.Button4Click(Sender: TObject);
begin
  TabControl1.TabIndex := 3;
end;


procedure Tfrm_Tickets.btnCadastrarTicketsClick(Sender: TObject);
begin
  TabControl1.TabIndex := 1;
end;

procedure Tfrm_Tickets.Button5Click(Sender: TObject);
begin
  TabControl1.TabIndex := 0;
end;

procedure Tfrm_Tickets.Calendar1DayClick(Sender: TObject);
var
  DataSelecionada: string;
  DataFormatada: string;
begin
  //edtData.Text := DateToStr(Calendar1.Date);

  DataSelecionada := DateToStr(Calendar1.Date);
  DataFormatada := FormatarData(DataSelecionada);

  PesquisarTicketsPorData(DataFormatada);

  InserirItensNaListView;


end;

procedure Tfrm_Tickets.distribuirTickets;
var
  i, quantidade, cd_funcionario, ticketsDisponiveis: Integer;
  nomeFuncionario: string;
begin
  if not TryStrToInt(edtQtd.Text, quantidade) then
  begin
    ShowMessage('Digite um número válido de tickets.');
    Exit;
  end;
  nomeFuncionario := ComboEdit1.Text;
  FDQFuncionarios1.Close;
  FDQFuncionarios1.SQL.Clear;
  FDQFuncionarios1.SQL.Add('select cd_funcionario from funcionarios where nm_funcionario = :nome');
  FDQFuncionarios1.ParamByName('nome').AsString := nomeFuncionario;
  FDQFuncionarios1.Open;
  cd_funcionario := FDQFuncionarios1.FieldByName('cd_funcionario').AsInteger;
  FDQFuncionarios1.Close;
  FDQTickets.SQL.Clear;
  FDQTickets.SQL.Add('select cpunt(*) as total from tickets where ie_situacao = ''A''');
  FDQTickets.Open;
  ticketsDisponiveis := FDQTickets.FieldByName('total').AsInteger;
  if quantidade > ticketsDisponiveis then
  begin
    ShowMessage('Não há tickets suficientes para distribuir. Tickets disponíveis: ' + IntToStr(ticketsDisponiveis));
    Exit;
  end;

  for i := 1 to quantidade do
  begin
    FDQTickets.Close;
    FDQTickets.SQL.Clear;
    FDQTickets.SQL.Add('update tickets set ');
    FDQTickets.SQL.Add('   cd_funcionario = :cd_funcionario, ');
    FDQTickets.SQL.Add('   nm_funcionario = :nm_funcionario, ');
    FDQTickets.SQL.Add('   dt_entrega = :dt_entrega, ');
    FDQTickets.SQL.Add('   ie_situacao = ''E'' ');
    FDQTickets.SQL.Add('where cd_ticket = (select cd_ticket from tickets where ie_situacao = ''A'' limit 1)');
    FDQTickets.ParamByName('cd_funcionario').AsInteger := cd_funcionario;
    FDQTickets.ParamByName('nm_funcionario').AsString := nomeFuncionario;
    FDQTickets.ParamByName('dt_entrega').AsDateTime := Now;
    FDQTickets.ExecSQL;
  end;
  ShowMessage(IntToStr(quantidade) + ' tickets atualizados para ' + nomeFuncionario + '.');
end;

procedure Tfrm_Tickets.InserirItensNaListView;
begin
  ListViewTickets.Items.Clear;

  FDQTickets.First;
  if ListViewTickets.Items.Count = 0 then
  begin
    with ListViewTickets.Items.Add do
    begin
      TListItemText(Objects.FindDrawable('txtIDTicket')).Text := 'Id';
      TListItemText(Objects.FindDrawable('txtNome')).Text := 'Funcionário';
      TListItemText(Objects.FindDrawable('txtDtentrega')).Text := 'Data Entrega';
      TListItemText(Objects.FindDrawable('txtIDTicket')).Font.Style := [TFontStyle.fsBold];
      TListItemText(Objects.FindDrawable('txtNome')).Font.Style := [TFontStyle.fsBold];
      TListItemText(Objects.FindDrawable('txtDtentrega')).Font.Style := [TFontStyle.fsBold];
    end;
  end;

  while not FDQTickets.Eof do
  begin
    with ListViewTickets.Items.Add do
    begin
      TListItemText(Objects.FindDrawable('txtIDTicket')).Text := FDQTickets.FieldByName('cd_ticket').AsString;
      TListItemText(Objects.FindDrawable('txtNome')).Text := FDQTickets.FieldByName('nm_funcionario').AsString;
      TListItemText(Objects.FindDrawable('txtDtentrega')).Text := Copy(FDQTickets.FieldByName('dt_entrega').AsString, 1, 19);
    end;

    FDQTickets.Next;
  end;
end;

procedure Tfrm_Tickets.inserirTicketsBanco(ticket: TTicket);
begin
  FDQTickets.Close;
  FDQTickets.SQL.Clear;
  FDQTickets.SQL.Add('insert into tickets (ie_situacao)');
  FDQTickets.SQL.Add(' values (:situacao)');
  FDQTickets.ParamByName('situacao').AsString := ticket.situacao;
  FDQTickets.ExecSQL;
end;

procedure Tfrm_Tickets.PesquisarTicketsPorData(const DataSelecionada: string);
begin

  FDQTickets.Close;
  FDQTickets.SQL.Clear;
  FDQTickets.SQL.Add('SELECT cd_ticket, cd_funcionario, nm_funcionario, ie_situacao, dt_entrega');
  FDQTickets.SQL.Add('FROM tickets');
  FDQTickets.SQL.Add('WHERE dt_entrega LIKE :DataSelecionada');
  FDQTickets.ParamByName('DataSelecionada').AsString := '%' + DataSelecionada + '%';
  FDQTickets.Open;


end;

procedure Tfrm_Tickets.preencherComboEdit;
begin
  FDQFuncionarios1.Close;
  FDQFuncionarios1.SQL.Clear;
  FDQFuncionarios1.SQL.Add('select nm_funcionario from funcionarios');
  FDQFuncionarios1.Open;
  ComboEdit1.Items.Clear;
  while not FDQFuncionarios1.Eof do
  begin
    ComboEdit1.Items.Add(FDQFuncionarios1.FieldByName('nm_funcionario').AsString);
    FDQFuncionarios1.Next;
  end;
  FDQFuncionarios1.Close;
end;


function Tfrm_Tickets.FormatarData(const DataOriginal: string): string;
var
  Dia, Mes, Ano: string;
begin
  if Length(DataOriginal) <> 10 then
  begin
    Result := '';
    Exit;
  end;

  Dia := Copy(DataOriginal, 1, 2);
  Mes := Copy(DataOriginal, 4, 2);
  Ano := Copy(DataOriginal, 7, 4);

  Result := Format('%s-%s-%s', [Ano, Mes, Dia]);
end;

end.
