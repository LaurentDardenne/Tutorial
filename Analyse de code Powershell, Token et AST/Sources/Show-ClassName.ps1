#Affiche les classes AST de Powershell v3 et >
#from : http://blog.coretech.dk/kaj/powershell-wpf-treeview-example/

#Requires -Version 3

throw "Modifier, dans la ligne suivante, le nom du répertoire contenant le module ExploreAST"

$env:PSModulePath=";VotreRépertoireSources\Modules"
Import-Module ExploreAST 


Add-Type -AssemblyName PresentationFramework
[XML]$XAML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell AST" Height="417" Width="395.712">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="14*" MaxHeight="14"/>
            <RowDefinition Height="27*" MaxHeight="26"/>
            <RowDefinition Height="269*"/>
            <RowDefinition Height="76*"/>
        </Grid.RowDefinitions>
        <TreeView Name="Tree" Grid.Row="2" Margin="2">
           <TreeView.ItemContainerStyle>
              <Style TargetType="TreeViewItem">
                  <Setter Property="TreeViewItem.IsExpanded" Value="True"/>
              </Style>
          </TreeView.ItemContainerStyle>    
        </TreeView>        
        <Label Content="AST classes:" Grid.Row="1"></Label>
    </Grid>

</Window>

'@
$Reader = (New-Object System.XML.XMLNodeReader $XAML)
$FORM = [Windows.Markup.XAMLReader]::Load($Reader)

$Tree = $FORM.FindName('Tree')

Function Add-TreeItem
{
    Param(
          $Name,
          $Parent,
          $Tag
          )

    #Add new TreeViewItem
    $ChildItem = New-Object System.Windows.Controls.TreeViewItem
    $ChildItem.Header = $Name
    $ChildItem.Name = $Name
    $ChildItem.Tag = "$Tag\$Name"
    #[Void]$ChildItem.Items.Add("*")
    [Void]$Parent.Items.Add($ChildItem)
    $ChildItem
}

Function Set-Classe
{
      #Groupe selon la classe ancêtre
     $Groups=Get-AstClasse|
              Select name,basetype|
              Sort basetype|
              Group basetype 
     
     foreach($Group in $Groups)
     {
         #Supprime le nom de l'espace de nom
        $Name=($Group.Name -split '\.')[-1]
          #la classe System.Management.Automation.Language.Ast dérive de System.Object
        if ($Name -eq 'object') {continue}   
        Write-warning "traite $Name"
        $TreeItem=Add-TreeItem -Name $Name -Parent $Tree -Tag "Root"
        foreach($Class in $Group.Group)
        {
          Add-TreeItem -Name $Class.Name -Parent $TreeItem -Tag $Name >$null
        }
     }
}

Set-Classe
$FORM.ShowDialog() | Out-Null

#Regroupe les méthodes par 'catégorie'
$ofs=" - "
[System.Management.Automation.Language.AstVisitor].GetMethods() |
  Where { 
   $_.Name -like 'Visit*'
  }|
  Foreach {
    "$(($_.Name.replace('Visit','') -creplace "[A-Z]"," $&"))"
  }|
  Group {
     ($_ -split ' ')[-1]
  }|
  Foreach { 
    Write-Warning "Name: $($_.Name)"
    Write-host "$($_.group)"
  }