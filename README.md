# Add,Del,Rename Registry[REG]

## 介紹: 新增、刪除、重命名機碼或機碼項目


- ## 機碼-[[參考]](https://docs.microsoft.com/zh-tw/powershell/scripting/samples/working-with-registry-keys?view=powershell-7.2)

**新增機碼:**
```
New-Item -Path Registry::'Reg_Keys'(如要覆蓋已存在的機碼則在後面加入-Force指令)
```

**刪除機碼:**
```
1. Remove-Item -Path Registry::'Reg_Keys'(強制刪除加入-Recurse指令)
2. Remove-Item -Path Registry::'Reg_Keys\*'(加入"\*"刪除機碼下所有子機碼)
```

**重新命名機碼:**
```
Rename-Item -Path Registry::"Reg_Keys" -NewName '新名稱' (若要顯示重新命名後的值加入-passthru指令)
```

**確認機碼是否存在:**
> Get-item -Path Registry::'Reg_Keys'(取得路徑，如不存在則返回錯誤)

**確認機碼下是否有其他子機碼存在:**
> Get-ChildItem -Path Registry::'Reg_Keys'(若要顯示所有包含的子機碼加入-Recurse指令，注意此指令不適用於Get-item)

**篩選:**
> Get-item -Path Registry | Select-Object Name (若只要顯示路徑名稱使用Select-Object)


</br>___________________________________________________________________________________________________________________________
</br>


- ## 機碼項目-[[參考]](https://docs.microsoft.com/zh-tw/powershell/scripting/samples/working-with-registry-entries?view=powershell-7.2)


**新增項目:**
```
New-ItemProperty -Path Registry::"Reg_Value_Path" -Name 'Reg_Vulue_Name' -PropertyType "Vulue_Type" -Value 'Reg_Vulue_Vulues'(如要覆蓋已存在的項目則在後面加入-Force指令)
```

**刪除項目:**
```
Remove-ItemProperty -Path Registry::"Reg_Value_Path" -Name 'Reg_Vulue_Name'
```

**重新命名項目:**
```
Rename-ItemProperty -Path Registry::"Reg_Value_Path" -Name 'Reg_Vulue_Name' -NewName '新名稱'(若要顯示重新命名後的值加入-passthru指令)
```

**確認項目是否存在:**
> Get-ItemProperty -Path Registry::'Reg_Value_Path' -name 'Reg_Vulue_Name'

**篩選:**
> Get-ItemProperty -Path Registry::'Reg_Value_Path' -name 'Reg_Vulue_Name' | findstr 'Reg_Vulue_Name' (若只要顯示項目名稱使用findstr)