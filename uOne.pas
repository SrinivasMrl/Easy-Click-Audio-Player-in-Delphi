unit uOne;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, mmsystem,
  Vcl.Imaging.GIFImg, Vcl.ExtCtrls, Vcl.MPlayer, Vcl.Buttons,ShellApi,
  Vcl.ComCtrls, activex, MMDevAPI, Vcl.Menus, Math, Registry;

type
  TfrmWhole = class(TForm)
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FilterComboBox1: TFilterComboBox;
    EdtFileName: TEdit;
    MediaPlayer1: TMediaPlayer;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    BtnShowInExplorer: TButton;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    lblVolume: TLabel;
    MainMenu1: TMainMenu;
    mnuFile1: TMenuItem;
    mnuOurDrumsChannel1: TMenuItem;
    Help1: TMenuItem;
    Label1: TLabel;
    tmrClose: TTimer;
    pnlClose: TPanel;
    lblCloser: TLabel;
    CrazyDrumsYouTubeChannel1: TMenuItem;
    Sa81: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    I1: TMenuItem;
    procedure DriveComboBox1Change(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
     procedure tc_PlayAudioFile;
    procedure FileListBox1Click(Sender: TObject);
    procedure FilterComboBox1Change(Sender: TObject);
    procedure BtnShowInExplorerClick(Sender: TObject);
    procedure ShowFolder(strFolder: string);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure mnuOurDrumsChannel1Click(Sender: TObject);
    function  ConvertBytes(Bytes: Int64): string;
    procedure DisplayFolderSize;
    procedure Help1Click(Sender: TObject);
    function MyMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons:TMsgDlgButtons;
            const ACaption: string = 'Hi'; DefaultButtonIndex: Integer = -1; HelpCtx: Longint =
    0): Integer;
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel2LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormShow(Sender: TObject);
    function LastCharPos(const S: string; const Chr: char): integer;
    function  GetORSetDefaultDirectoryStoredInRegistry(StoreThisValue: String) : String;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrCloseTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CrazyDrumsYouTubeChannel1Click(Sender: TObject);
    procedure Sa81Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    endpointVolume: IAudioEndpointVolume;
    LastBeepTime:TDatetime;
    onFormLoadingGoingON : Boolean;
    slFileNames : TStringList;
    strCloser : string;
  end;

var
  frmWhole: TfrmWhole;

implementation

{$R *.dfm}


procedure TfrmWhole.FormCreate(Sender: TObject);
 var Dire : String;
  deviceEnumerator: IMMDeviceEnumerator;
  defaultDevice: IMMDevice;
  VolumeLevel : Single;
  strTemp,strTemp2 : String;
  I, dcCount: Integer;
begin
try
  onFormLoadingGoingON := True;
  slFileNames := TStringList.Create;
  strCloser := '       !! Have a Great Day !!       ';
  EndpointVolume:=nil;
  CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, deviceEnumerator);
  deviceEnumerator.GetDefaultAudioEndpoint(eRender, eConsole, defaultDevice);
  defaultDevice.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, endpointVolume);
  lastbeeptime:=now;
  EndpointVolume.GetMasterVolumeLevelScaler(VolumeLevel);
  TrackBar1.Position := round(VolumeLevel * 100);

  lastbeeptime:=now;
  strTemp := '';
  Dire :=    GetORSetDefaultDirectoryStoredInRegistry(strTemp);
  DriveComboBox1.ItemIndex := DriveComboBox1.Items.Count -1;
  if directoryExists(Dire) then
    DirectoryListBox1.Directory := Dire
     else
       DirectoryListBox1.Directory := 'C:\';

   dcCount := 0; // Default is C:
   strTemp := ExtractFileDrive(DirectoryListBox1.Directory);
   for I := 0 to DriveComboBox1.Items.Count -1 do
     begin
       DriveComboBox1.Items[i] := UpperCase(DriveComboBox1.Items[i]);
       strTemp2 := DriveComboBox1.Items[i];
      if Pos(UpperCase(strTemp),strTemp2 ) > 0   then
       dcCount := I;
     end;
   DriveComboBox1.ItemIndex := dcCount;

 MediaPlayer1.Width := 249;
 MediaPlayer1.Height := 25;

finally
    onFormLoadingGoingON := False;
end;
end;

procedure TfrmWhole.FormShow(Sender: TObject);
begin
 DirectoryListBox1.SetFocus;
end;

procedure TfrmWhole.Help1Click(Sender: TObject);
 var sHelpNAbout : String;
begin
sHelpNAbout := 'On the Left Side Box '  + #13 + #10+  '------------------------------' + #13+#10+
 'Double Click To Change Folder ' + #13+#10+  #13+#10+
 'On the Right Side box'  + #13+#10+  '------------------------------' +
  #13+#10+  'To Play the File'+ #13+#10+
 'Click on File Name [OR]'  + #13+#10+
 'Use ARROW KEYS of Key Board '  + #13+#10+
  #13+#10+ ' This is a Freeware !! May 2021, India ' +
  #13+#10+' Angry Gods !! Covid B1.617 Variant 1 Batting like Anything';
  MyMessageDlg(sHelpNAbout,mtCustom, [mbOk],'Hi Buddy !!');
end;

procedure TfrmWhole.TrackBar1Change(Sender: TObject);
  var quadrum : integer;
var
  VolumeLevel: Single;
begin
  if onFormLoadingGoingON then EXIT;

  if endpointVolume = nil then Exit;
  with Trackbar1 do volumeLevel:= Position/max;
  endpointVolume.SetMasterVolumeLevelScalar(VolumeLevel, nil);
  messagebeep(MB_IconExclamation); {48}
end;

procedure TfrmWhole.DriveComboBox1Change(Sender: TObject);
begin
   DirectoryListBox1.Drive := DriveComboBox1.Drive;
   FileListBox1.ItemIndex := -1;

end;

procedure TfrmWhole.DirectoryListBox1Change(Sender: TObject);
begin
try
  slFileNames.Clear;
  FileListBox1.Items.Clear;
  FileListBox1.Directory := DirectoryListBox1.Directory;
  StatusBar1.Panels[0].Text := FileListBox1.Directory;
  StatusBar1.Panels[1].Text := IntToStr(FileListBox1.Items.Count) + '  Files';
  StatusBar1.Panels[2].Text := '';
  StatusBar1.Panels[3].Text := '';
  DisplayFolderSize;
  FileListBox1.ItemIndex := -1;
except
end;
end;

procedure TfrmWhole.FileListBox1Click(Sender: TObject);
begin
if FileListBox1.ItemIndex > 0 then
    tc_PlayAudioFile;
end;

procedure TfrmWhole.FilterComboBox1Change(Sender: TObject);
begin
try
  StatusBar1.Panels[1].Text := IntToStr(FileListBox1.Items.Count) + '  Files';
  StatusBar1.Panels[2].Text := '';
  StatusBar1.Panels[3].Text := '';
  DisplayFolderSize;
  FileListBox1.ItemIndex := -1;
except
end;
end;


procedure TfrmWhole.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmWhole.BtnShowInExplorerClick(Sender: TObject);
begin
 if not (FileListBox1.Directory = '') then
    ShowFolder(FileListBox1.Directory);
end;


procedure TfrmWhole.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(Handle, 'open', 'https://www.youtube.com/channel/UCbpigaprk_b2aLnOyhA3uvA', nil, nil, SW_SHOWNORMAL) ;
end;

procedure TfrmWhole.LinkLabel2LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
 ShellExecute(Handle, 'open', 'http://www.saibharadwaja.org', nil, nil, SW_SHOWNORMAL) ;
end;

procedure TfrmWhole.mnuOurDrumsChannel1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://www.youtube.com/channel/UCbpigaprk_b2aLnOyhA3uvA', nil, nil, SW_SHOWNORMAL) ;
end;

procedure TfrmWhole.tc_PlayAudioFile;
 var theFileName : String;
begin
TRY
 if FileListBox1.Items.Count > 0 then
 begin
  // theFileName := slFileNames[FileListBox1.ItemIndex];
   theFileName := FileListBox1.FileName;
   EdtFileName.Color := clBtnFace;
   EdtFileName.Text := Copy(theFileName, LastCharPos(theFileName,'\') +1, Length(theFileName)-1);
   EdtFileName.Refresh;
   Application.ProcessMessages;
   MediaPlayer1.Close;
   MediaPlayer1.FileName := theFileName;

   MediaPlayer1.Open;
  //  MediaPlayer1.Wait := True;
   MediaPlayer1.Play;
   MediaPlayer1.Refresh;
  //PlaySound(PChar(FileListBox1.FileName), 0, SND_SYNC);
  MediaPlayer1.Enabled := True;
  Application.ProcessMessages;
 end;
 Except
  EdtFileName.Text := 'There is some problem with this file ?!';
  EdtFileName.Color := clRed;
 End;
end;

procedure TfrmWhole.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels[3].Text := formatdatetime(' dddd d mmmm yyyy hh:nn AM/PM  ', now);
end;



procedure TfrmWhole.tmrCloseTimer(Sender: TObject);
 var  I, loflable : Integer;
begin
  lblCloser.Visible := True;
  loflable:= length(lblCloser.Caption);
  lblCloser.Caption := Copy(strCloser, 0, loflable +1);
  if (length(lblCloser.Caption)+ 1 >= length(strCloser))  then
     tmrClose.Interval := 500;

  if (length(lblCloser.Caption) >= length(strCloser))  then
   begin
        strCloser := '';
        tmrClose.Enabled := False;
        Close;
   end;
    Application.ProcessMessages;
end;

procedure TfrmWhole.Sa81Click(Sender: TObject);
begin
   ShellExecute(Handle, 'open', 'http://www.saibharadwaja.org', nil, nil, SW_SHOWNORMAL) ;
end;

procedure TfrmWhole.ShowFolder(strFolder: string);
begin
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(strFolder),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

procedure TfrmWhole.DisplayFolderSize;
var
  F: File;
  i,intFolderSize: integer;
begin
 EXIT;
try
  intFolderSize := 0;
  FileListBox1.Enabled := False;
  try
    for i := 0 to (FileListBox1.Items.Count - 1) do
     begin
      if Pos('||',FileListBox1.Items.Strings[i]) <= 0  then
       begin
       AssignFile(F, FileListBox1.Items.Strings[i]);
       Reset(F, 1);
       slFileNames.Add(FileListBox1.Items.Strings[i]);
       FileListBox1.Items.Strings[i] := FileListBox1.Items.Strings[i] +' || ' + (ConvertBytes(FileSize(F)) );
       intFolderSize := intFolderSize + FileSize(F);
       CloseFile(F);
     end;
     end;
     StatusBar1.Panels[2].Text := ConvertBytes(intFolderSize);
  except
  end;
  finally
    StatusBar1.Panels[2].Text := '';
    FileListBox1.Enabled := True;
  end;
end;


function TfrmWhole.ConvertBytes(Bytes: Int64): string;
const
  Description: Array [0 .. 8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  i: Integer;
begin
  i := 0;

  while Bytes > Power(1024, i + 1) do
    Inc(i);

  Result := FormatFloat('###0.#', Bytes / IntPower(1024, i)) + ' ' + Description[i];
end;


procedure TfrmWhole.CrazyDrumsYouTubeChannel1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://www.youtube.com/channel/UCbpigaprk_b2aLnOyhA3uvA', nil, nil, SW_SHOWNORMAL) ;
end;

function TfrmWhole.MyMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons:
  TMsgDlgButtons;
  const ACaption: string = 'Hi'; DefaultButtonIndex: Integer = -1; HelpCtx: Longint =
    0): Integer;
var
  Index: Integer;
  ButtonIndex: Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons) do
  try
    HelpContext := HelpCtx;
    if ACaption <> '' then
      Caption := ACaption;
    if DefaultButtonIndex >= 0 then
    begin
      ButtonIndex := -1;
      for Index := 0 to ControlCount - 1 do
      begin
        if Controls[Index] is TButton then
        begin
          Inc(ButtonIndex);
          TButton(Controls[Index]).Default := ButtonIndex = DefaultButtonIndex;
          if ButtonIndex = DefaultButtonIndex then
            ActiveControl := TButton(Controls[Index]);
        end;
      end;
    end;
    Result := ShowModal;
  finally
    free;
  end;
end;

function  TfrmWhole.LastCharPos(const S: string; const Chr: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := length(S) downto 1 do
    if S[i] = Chr then
      Exit(i);
end;

function TfrmWhole.GetORSetDefaultDirectoryStoredInRegistry(StoreThisValue: String) : String;
var
  RegistryEntry: TRegistry;  strTemp : String;
begin
try
try
  result := '';
  RegistryEntry := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  RegistryEntry.RootKey:= HKEY_CURRENT_USER;
  if (not RegistryEntry.KeyExists('Software\AudioRackByTCSri')) then
    begin //VERY FIRST TIME
      RegistryEntry.Access:= KEY_WRITE or KEY_WOW64_64KEY;
      if RegistryEntry.OpenKey('Software\AudioRackByTCSri',True) then
         RegistryEntry.WriteString('DefDir','C:\' );

      strTemp := 'C:\';
    end
    else
  if (StoreThisValue <> '') then
  begin       //WRITING
      RegistryEntry.Access:= KEY_WRITE or KEY_WOW64_64KEY;
      RegistryEntry.OpenKey('Software\AudioRackByTCSri\',True);
      RegistryEntry.WriteString('DefDir',StoreThisValue );
  end
  else
    begin       //READING
    if RegistryEntry.OpenKey('Software\AudioRackByTCSri\',True) then
         strTemp := RegistryEntry.ReadString('DefDir');
    end;
  RegistryEntry.CloseKey();
  RegistryEntry.Free;
except
end;
finally
  result := strTemp;
end;
end;

procedure TfrmWhole.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmWhole.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 if strCloser <> '' then
   begin
     lblCloser.Caption := '';
     pnlClose.Color := rgb(192,192,192);
     pnlClose.Visible := True;
     tmrClose.Enabled:= True;
     GetORSetDefaultDirectoryStoredInRegistry(DirectoryListBox1.Directory);
     CanClose := False;
   end;
end;

end.
