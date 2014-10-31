Attribute VB_Name = "modCommon"
Global fso As New CFileSystem2
Global frmMain As Object

Private Declare Function SHGetPathFromIDList Lib "shell32" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
Private Declare Function SHGetSpecialFolderLocation Lib "shell32" (ByVal hWndOwner As Long, ByVal nFolder As Long, pidl As Long) As Long
Private Declare Sub CoTaskMemFree Lib "ole32" (ByVal pv As Long)
Public Declare Function ShowWindow Lib "user32" (ByVal hWnd As Long, ByVal nCmdShow As Long) As Long

Public Function UserDeskTopFolder() As String
    Dim idl As Long
    Dim p As String
    Const MAX_PATH As Long = 260
      
      p = String(MAX_PATH, Chr(0))
      If SHGetSpecialFolderLocation(0, 0, idl) <> 0 Then Exit Function
      SHGetPathFromIDList idl, p
      
      UserDeskTopFolder = Left(p, InStr(p, Chr(0)) - 1)
      CoTaskMemFree idl
        
      UserDeskTopFolder = UserDeskTopFolder & "\analysis"
      
      If Not fso.FolderExists(UserDeskTopFolder) Then
            fso.CreateFolder UserDeskTopFolder
      End If
  
End Function

Sub SetLiColor(li As ListItem, newcolor As Long)
    Dim f As ListSubItem
'    On Error Resume Next
    li.ForeColor = newcolor
    For Each f In li.ListSubItems
        f.ForeColor = newcolor
    Next
End Sub

Public Sub LV_ColumnSort(ListViewControl As ListView, Column As ColumnHeader)
     On Error Resume Next
    With ListViewControl
       If .SortKey <> Column.Index - 1 Then
             .SortKey = Column.Index - 1
             .SortOrder = lvwAscending
       Else
             If .SortOrder = lvwAscending Then
              .SortOrder = lvwDescending
             Else
              .SortOrder = lvwAscending
             End If
       End If
       .Sorted = -1
    End With
End Sub

Function LaunchStrings(data As String, Optional isPath As Boolean = False)

    Dim b() As Byte
    Dim f As String
    Dim exe As String
    Dim h As Long
    
    On Error Resume Next
    
    exe = App.path & IIf(isIde(), "\..\..", "") & "\shellext.exe"
    If Not fso.FileExists(exe) Then
        MsgBox "Could not launch strings shellext not found", vbInformation
        Exit Function
    End If
    
    If isPath Then
        If fso.FileExists(data) Then
            f = data
        Else
            MsgBox "Can not launch strings, File not found: " & data, vbInformation
            Exit Function
        End If
    Else
        b() = StrConv(data, vbFromUnicode, LANG_US)
        f = fso.GetFreeFileName(Environ("temp"), ".bin")
        h = FreeFile
    End If
    
    Open f For Binary As h
    Put h, , b()
    Close h
    
    Shell exe & " """ & f & """ /peek"

End Function

Function LaunchExternalHexViewer(data As String, Optional isPath As Boolean = False, Optional Base As String = Empty)

    Dim b() As Byte
    Dim f As String
    Dim exe As String
    Dim h As Long
    
    On Error Resume Next
    
    If Len(Base) > 0 Then Base = "/base=" & Replace(Base, "`", Empty)
    
    exe = App.path & IIf(isIde(), "\..\..", "") & "\shellext.exe"
    If Not fso.FileExists(exe) Then
        MsgBox "Could not launch strings shellext not found", vbInformation
        Exit Function
    End If
    
    If isPath Then
        If fso.FileExists(data) Then
            f = data
        Else
            MsgBox "Can not launch strings, File not found: " & data, vbInformation
            Exit Function
        End If
    Else
        b() = StrConv(data, vbFromUnicode, LANG_US)
        f = fso.GetFreeFileName(Environ("temp"), ".bin")
        h = FreeFile
    End If
    
    Open f For Binary As h
    Put h, , b()
    Close h
    
    Shell "cmd.exe /c " & exe & " """ & f & """" & IIf(Len(Base) > 0, " " & Trim(Base), "") & " /hexv"

End Function


Function isIde() As Boolean
    On Error GoTo hell
    Debug.Print 1 \ 0
Exit Function
hell: isIde = True
End Function

Function FileExists(path) As Boolean
  On Error Resume Next
  If Len(path) = 0 Then Exit Function
  If Dir(path, vbHidden Or vbNormal Or vbReadOnly Or vbSystem) <> "" Then FileExists = True
End Function

Sub RestoreFormSizeAnPosition(f As Form)

    On Error GoTo hell
    Dim s
    
    s = GetMySetting(f.name & "_pos", "")
    
    If Len(s) = 0 Then Exit Sub
    If occuranceCount(s, ",") <> 3 Then Exit Sub
    
    s = Split(s, ",")
    f.Left = s(0)
    f.Top = s(1)
    f.Width = s(2)
    f.Height = s(3)
    
    Exit Sub
hell:
End Sub

Sub SaveFormSizeAnPosition(f As Form)
    On Error Resume Next
    Dim s As String
    If f.WindowState <> 0 Then Exit Sub 'vbnormal
    s = f.Left & "," & f.Top & "," & f.Width & "," & f.Height
    SaveMySetting f.name & "_pos", s
End Sub

Function GetMySetting(key, def)
    GetMySetting = GetSetting("iDefense", App.EXEName, key, def)
End Function

Sub SaveMySetting(key, Value)
    SaveSetting "iDefense", App.EXEName, key, Value
End Sub

Function occuranceCount(haystack, match) As Long
    On Error Resume Next
    Dim tmp
    tmp = Split(haystack, match, , vbTextCompare)
    occuranceCount = UBound(tmp)
    If Err.Number <> 0 Then occuranceCount = 0
End Function

