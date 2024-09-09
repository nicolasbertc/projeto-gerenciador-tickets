unit uPrincipal;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl, FMX.Layouts;


type
  Tfrm_Principal = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
     { Public declarations }
  end;
var
  frm_Principal: Tfrm_Principal;
implementation
{$R *.fmx}
uses uFuncionario, uTickets;

procedure Tfrm_Principal.Button1Click(Sender: TObject);
begin
  frm_Principal.hide;
  frm_Funcionario.TabControl.TabIndex := 0;
  frm_Funcionario.Show;
end;

procedure Tfrm_Principal.Button2Click(Sender: TObject);
begin
  frm_Principal.hide;
  frm_Tickets.TabControl1.TabIndex := 0;
  frm_Tickets.Show;
end;


end.
