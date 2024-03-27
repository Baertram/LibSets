' Excel makro to find and replace the SavedVariables lua table entries like e.g. [1] = "660|26|Imperial City|584|Imperial City",
' with the needed Excel format 660|26|Imperial City|584|Imperial City
' Will completely read column A1 to A(End) and output to columns B1 to B(End)
Sub Clean_ESO_SavedVars()
    Dim strPattern As String: strPattern = "\[.*\] ="
    Dim strReplace As String: strReplace = ""
    Dim myreplace As Long
    Dim s1, strInput, sClean As String
    Dim Myrange As Range
    Dim i, lrowA As Long

    Set regEx = CreateObject("VBScript.RegExp")
    'Set Myrange = ActiveSheet.Range("A1")

    'Select column A completely (to bottom)
    lrowA = ActiveSheet.Cells(Rows.Count, 1).End(xlUp).Row


    'For Each row in column 1 (A)
    For i = 1 To lrowA
        If strPattern <> "" Then
            strInput = Cells(i, 1).Value
            'Remove trailing , and " "
            s1 = Replace(strInput, ",", "")
            s1 = Replace(s1, """", "")
            'Remove leading [*] index of table by RegEx
            With regEx
                .Global = True
                .MultiLine = False
                .IgnoreCase = True
                .Pattern = strPattern
            End With

            If regEx.TEST(s1) Then
                sClean = (regEx.Replace(s1, strReplace))

                 'Myrange.Value = (regEx.Replace(strInput, strReplace))
            Else
                sClean = s1
            End If
            'Write the output to column 1 (A) + 1 = B
            Cells(i, 2).Value = sClean
        End If
    Next

    Set regEx = Nothing

End Sub


'===============================================================================
' Excel makro to split up the ESO SavedVariables lua table data in column A at the separator |
' and transfer it to the columns B, C, ...
' Will completely read column A1 to A(End) and output to columns B1 to B(End)
Sub ESO_Split_SavedVars_to_Excel()

    Dim separator As String: separator = "|"
    Dim strPattern As String: strPattern = "\[.*\] ="
    Dim strReplace As String: strReplace = ""
    Dim myreplace As Long
    Dim s1, strInput, sClean, sCleanPart As String
    Dim Myrange As Range
    Dim rowNr, columnNr, lrowA As Long
    Dim i As Integer
    Dim tSplitStrs As Variant

    Set regEx = CreateObject("VBScript.RegExp")
    'Set Myrange = ActiveSheet.Range("A1")

    'Select column A completely (to bottom)
    lrowA = ActiveSheet.Cells(Rows.Count, 1).End(xlUp).Row


    'For Each row in column 1 (A)
    For rowNr = 1 To lrowA
        If strPattern <> "" Then
            strInput = Cells(rowNr, 1).Value
            'Remove trailing , and " "
            s1 = Replace(strInput, ",", "")
            s1 = Replace(s1, """", "")

            With regEx
                .Global = True
                .MultiLine = False
                .IgnoreCase = True
                .Pattern = strPattern
            End With

            If regEx.TEST(s1) Then
                'Remove leading [*] index of table by RegEx
                 sClean = (regEx.Replace(s1, strReplace))
            Else
                'Just take the value as it is
                sClean = s1

            End If

            'Split the string at separator | into columns B, C, ...
            columnNr = 2 ' = B


            'Loop sClean, split at | into sCleanPart, then write to next column

            ReDim FullName(3)
            tSplitStrs = Split(sClean, separator)
            For i = 0 To UBound(tSplitStrs)
               Cells(rowNr, columnNr + i).Value = tSplitStrs(i)
            Next i
        End If
    Next

    Set regEx = Nothing
End Sub



