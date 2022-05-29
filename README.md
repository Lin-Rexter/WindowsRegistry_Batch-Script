# Add,Delete,Rename,Setting Registry[REG]

## Introduction: Batch scripts for Create, Delete, Rename Setting Registry Keys or Entries.


- ## Registry Keys [[Reference]](https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-keys?view=powershell-7.2)

**Creating Keys:**
```
New-Item -Path Registry::'Reg keys path'(If you want to overwrite a pre-existing use -Force)
```

**Removing Keys:**
```
1. Remove-Item -Path Registry::'Reg keys path'(Force delete use -Recurse)
2. Remove-Item -Path Registry::'Reg keys path\*'(Add"\*"delete all subkeys)
```

**Rename Keys:**
```
Rename-Item -Path Registry::"Reg keys path" -NewName 'New name' (Display the renamed value use -passthru)
```

**Check the existence of the keys:**
> Get-item -Path Registry::'Reg keys path'(Get keys path)

**Check the existence of the subkeys:**
> Get-ChildItem -Path Registry::'Reg keys path'(Show contained items use -Recurse)

**Only display path:**
> Get-item -Path Registry::'Reg keys path' | Select-Object Name
>> Get-ChildItem -Path Registry::'Reg keys path' | Select-Object Name

</br>___________________________________________________________________________________________________________________________
</br>


- ## Registry Entries [[Reference]](https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries?view=powershell-7.2)


**Creating New Entries:**
```
New-ItemProperty -Path Registry::"Reg Entries Path" -Name 'Reg Entries Name' -PropertyType "Vulue Type" -Value 'Vulues'(If you want to overwrite a pre-existing use -Force)
```

**Deleting Entries:**
```
Remove-ItemProperty -Path Registry::"Reg Entries Path" -Name 'Reg Entries Name'
```

**Renaming Entries:**
```
Rename-ItemProperty -Path Registry::"Reg Entries Path" -Name 'Reg Entries Name' -NewName 'New name'(Display the renamed value use -passthru)
```

**Setting Entries Values:**
```
Set-ItemProperty -Path Registry::"Reg Entries Path" -Name 'Reg Entries Name' -Value 'New Values'(Display the renamed value use -passthru)
```

**Check the existence of the entries:**
> Get-ItemProperty -Path Registry::'Reg Entries Path' -name 'Reg Entries Name'

**Displays specifying item:**
> Get-ItemProperty -Path Registry::'Reg Entries Path' -name 'Reg Entries Name' | findstr 'Reg Entries Name'