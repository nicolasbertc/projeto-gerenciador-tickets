unit uFuncionario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.TabControl,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFuncionario = record
    codigo, cpf : Integer;
    nome, situacao : string;
    dt_criacao, dt_edicao : TDateTime;
    //TDateField e TDateTime
  end;


  Tfrm_Funcionario = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    Layout2: TLayout;
    btnAdicionarFunc: TButton;
    edtPesquisa: TEdit;
    btnVoltar: TButton;
    TabControl: TTabControl;
    Pesquisa: TTabItem;
    Cadastro: TTabItem;
    btnInserir: TButton;
    Label3: TLabel;
    Label4: TLabel;
    edtNome: TEdit;
    edtCpf: TEdit;
    FDQFuncionarios: TFDQuery;
    FDConnection1: TFDConnection;
    Layout3: TLayout;
    Layout4: TLayout;
    Label2: TLabel;
    Label5: TLabel;
    Layout5: TLayout;
    Layout6: TLayout;
    btnPesquisar: TButton;
    ListView1: TListView;
    Editar: TTabItem;
    Label6: TLabel;
    Layout7: TLayout;
    Layout8: TLayout;
    Layout10: TLayout;
    edtEdicaoNome: TEdit;
    Label8: TLabel;
    Layout9: TLayout;
    edtEdicaoCpf: TEdit;
    Label7: TLabel;
    btnSalvarEdicao: TButton;
    edtEdicaoSituacao: TCheckBox;
    edtEdicaoCodigo: TEdit;
    procedure btnAdicionarFuncClick(Sender: TObject);
    procedure inserirFuncionarioBanco(funcionario : TFuncionario);
    procedure btnInserirClick(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure atualizaFuncBanco();
    procedure inserirFuncLista(funcionario: TFuncionario);
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    function buscarFuncionarioBanco(id_funcionario : integer) : TFuncionario;
    procedure btnSalvarEdicaoClick(Sender: TObject);

    procedure editarFuncBanco(funcionario : Tfuncionario);
    procedure btnVoltarClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnVoltarEditarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Funcionario: Tfrm_Funcionario;


implementation

{$R *.fmx}

uses uPrincipal, uTickets;



procedure Tfrm_Funcionario.atualizaFuncBanco;
var vFuncionario : TFuncionario;
begin
  FDQFuncionarios.Close;
  FDQFuncionarios.SQL.Clear;
  FDQFuncionarios.SQL.Add('select * from funcionarios');

  if edtPesquisa.Text <> '' then
  begin
    FDQFuncionarios.SQL.Add('where nm_funcionario like :pesquisa');
    FDQFuncionarios.ParamByName('pesquisa').AsString := edtPesquisa.Text;
  end;

  FDQFuncionarios.Open();
  FDQFuncionarios.First;

  ListView1.Items.Clear;
  
  
  while not FDQFuncionarios.Eof do
  begin
    vFuncionario.codigo := FDQFuncionarios.FieldByName('cd_funcionario').AsInteger;
    vFuncionario.nome := FDQFuncionarios.FieldByName('nm_funcionario').AsString;
    vFuncionario.cpf := FDQFuncionarios.FieldByName('cd_cpf').AsInteger;
    vFuncionario.situacao := FDQFuncionarios.FieldByName('ie_situacao').AsString;


    inserirFuncLista(vFuncionario);

    FDQFuncionarios.Next;
  end;
end;

procedure Tfrm_Funcionario.btnAdicionarFuncClick(Sender: TObject);
begin
  edtNome.Text := '';
  edtCpf.Text := '';
  TabControl.TabIndex := 1;
end;

procedure Tfrm_Funcionario.btnInserirClick(Sender: TObject);
var vFuncionario : TFuncionario;
begin
  vFuncionario.nome := edtNome.Text;
  vFuncionario.cpf := StrToInt(edtCpf.Text);
  vFuncionario.situacao := 'A';

  inserirFuncionarioBanco(vFuncionario);
end;

procedure Tfrm_Funcionario.btnPesquisarClick(Sender: TObject);
begin
  atualizaFuncBanco;
end;



procedure Tfrm_Funcionario.btnSalvarEdicaoClick(Sender: TObject);
var vFuncionario : TFuncionario;
    id_funcionario : integer;
     situacao : string;
begin

  vFuncionario.codigo := StrToInt(edtEdicaoCodigo.Text);
  vFuncionario.nome := edtEdicaoNome.Text;
  vFuncionario.cpf := StrToInt(edtEdicaoCpf.Text);
  situacao := FDQFuncionarios.FieldByName('ie_situacao').AsString;
  if edtEdicaoSituacao.IsChecked = True then
  begin
    vFuncionario.situacao := 'A';
  end
  else if edtEdicaoSituacao.IsChecked = True then
  begin
    vFuncionario.situacao := 'I';
  end;

  vFuncionario.dt_edicao := Now;



  editarFuncBanco(vFuncionario);

  ShowMessage('Funcionario alterado com sucesso!');

  TabControl.TabIndex := 0;
  atualizaFuncBanco;

end;


procedure Tfrm_Funcionario.btnVoltarClick(Sender: TObject);
begin
  frm_Funcionario.Close;
  frm_Principal.Show;
end;



procedure Tfrm_Funcionario.btnVoltarEditarClick(Sender: TObject);
begin
  frm_Funcionario.show;
  TabControl.Index := 0;
end;

function Tfrm_Funcionario.buscarFuncionarioBanco(id_funcionario: integer): TFuncionario;
var vFuncionario : TFuncionario;
begin
  FDQFuncionarios.Close;
  FDQFuncionarios.SQL.Clear;
  FDQFuncionarios.SQL.Add('select * from funcionarios ');
  FDQFuncionarios.SQL.Add('where cd_funcionario = :codigo');
  FDQFuncionarios.ParamByName('codigo').AsInteger := id_funcionario;

  FDQFuncionarios.Open();

  vFuncionario.codigo := id_funcionario;
  vFuncionario.nome := FDQFuncionarios.FieldByName('nm_funcionario').AsString;
  vFuncionario.cpf := FDQFuncionarios.FieldByName('cd_cpf').AsInteger;
  vFuncionario.situacao := FDQFuncionarios.FieldByName('ie_situacao').AsString;

  Result := vFuncionario;
end;

procedure Tfrm_Funcionario.Button1Click(Sender: TObject);
begin
    TabControl.Index := 0;
end;

procedure Tfrm_Funcionario.editarFuncBanco(funcionario: Tfuncionario);
begin

  FDQFuncionarios.Close;
  FDQFuncionarios.SQL.Clear;
  FDQFuncionarios.SQL.Add('update funcionarios set ');
  FDQFuncionarios.SQL.Add('   nm_funcionario = :nome, ');
  FDQFuncionarios.SQL.Add('   cd_cpf = :cpf, ');
  FDQFuncionarios.SQL.Add('   ie_situacao = :situacao, ');
  FDQFuncionarios.SQL.Add('   dt_edicao = :dt_edicao ');
  FDQFuncionarios.SQL.Add('where cd_funcionario = :codigo');

  FDQFuncionarios.ParamByName('codigo').AsInteger := funcionario.codigo;
  FDQFuncionarios.ParamByName('nome').AsString := funcionario.nome;
  FDQFuncionarios.ParamByName('cpf').AsInteger := funcionario.cpf;
  FDQFuncionarios.ParamByName('situacao').AsString := funcionario.situacao;
  FDQFuncionarios.ParamByName('dt_edicao').AsDateTime := Now;

  FDQFuncionarios.ExecSQL;

end;


procedure Tfrm_Funcionario.inserirFuncionarioBanco(funcionario: TFuncionario);
begin

  FDQFuncionarios.Close;
  FDQFuncionarios.SQL.Clear;
  FDQFuncionarios.SQL.Add('select count(*) from funcionarios where cd_cpf = :cpf');
  FDQFuncionarios.ParamByName('cpf').AsInteger := funcionario.cpf;
  FDQFuncionarios.Open;
  if FDQFuncionarios.Fields[0].AsInteger > 0 then
  begin
    ShowMessage('Já existe um funcionário cadastrado com este CPF.');
    Exit;
  end;


  FDQFuncionarios.Close;
  FDQFuncionarios.SQL.Clear;
  FDQFuncionarios.SQL.Add('insert into funcionarios (nm_funcionario, cd_cpf, ie_situacao, dt_criacao, dt_edicao)');
  FDQFuncionarios.SQL.Add(' values (:nome, :cpf, :situacao, :dt_criacao, :dt_edicao)');
  FDQFuncionarios.ParamByName('nome').AsString := funcionario.nome;
  FDQFuncionarios.ParamByName('cpf').AsInteger := funcionario.cpf;
  FDQFuncionarios.ParamByName('situacao').AsString := funcionario.situacao;
  FDQFuncionarios.ParamByName('dt_criacao').AsDateTime := Now;
  FDQFuncionarios.ParamByName('dt_edicao').AsDateTime := Now;

  FDQFuncionarios.ExecSQL;


  ShowMessage('Funcionário criado com sucesso!');
  TabControl.TabIndex := 0;

end;


procedure Tfrm_Funcionario.inserirFuncLista(funcionario : TFuncionario);
begin
  if ListView1.Items.Count = 0 then
  begin
    with ListView1.Items.Add do
    begin
      TListItemText(Objects.FindDrawable('txtID')).Text := 'Código';
      TListItemText(Objects.FindDrawable('txtNome')).Text := 'Nome';
      TListItemText(Objects.FindDrawable('txtCpf')).Text := 'CPF';
      TListItemText(Objects.FindDrawable('txtAtivo')).Text := 'Ativo';
      TListItemText(Objects.FindDrawable('txtID')).Font.Style := [TFontStyle.fsBold];
      TListItemText(Objects.FindDrawable('txtNome')).Font.Style := [TFontStyle.fsBold];
      TListItemText(Objects.FindDrawable('txtCpf')).Font.Style := [TFontStyle.fsBold];
      TListItemText(Objects.FindDrawable('txtAtivo')).Font.Style := [TFontStyle.fsBold];
    end;
  end;

  with ListView1.Items.Add do
  begin
    TListItemText(Objects.FindDrawable('txtID')).Text := IntToStr(funcionario.codigo);
    TListItemText(Objects.FindDrawable('txtNome')).Text := funcionario.nome;
    TListItemText(Objects.FindDrawable('txtCpf')).Text := IntToStr(funcionario.cpf);
    TListItemText(Objects.FindDrawable('txtAtivo')).Text := funcionario.situacao;
  end;
end;





procedure Tfrm_Funcionario.ListView1ItemClickEx(const Sender: TObject;ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var vFuncionario : TFuncionario;
    id_funcionario : integer;
    situacao : string;
begin
  id_funcionario := StrToInt(TListItemText(ListView1.Items[ItemIndex].Objects.FindDrawable('txtID')).Text);

  vFuncionario := buscarFuncionarioBanco(id_funcionario);


  edtEdicaoCodigo.Text := IntToStr(vFuncionario.codigo);
  edtEdicaoNome.Text := vFuncionario.nome;
  edtEdicaoCpf.Text := IntToStr(vFuncionario.cpf);
  situacao := FDQFuncionarios.FieldByName('ie_situacao').AsString;
  if situacao = 'A' then
    edtEdicaoSituacao.IsChecked := True
  else if situacao = 'I' then
    edtEdicaoSituacao.IsChecked := False;


  TabControl.TabIndex := 2;

end;



end.
