# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'GIF Viewer'
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'

# Create a PictureBox to display the GIF
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.SizeMode = 'StretchImage'
$pictureBox.Dock = 'Fill'

# Load the GIF
$gifPath = 'C:\Users\theob\Documents\GitHub\Scripts\dan6t0z-5cc622d3-63b8-4f82-b158-0230e658e9c0.gif'  # Change this to the path of your GIF
$pictureBox.Image = [System.Drawing.Image]::FromFile($gifPath)

# Add PictureBox to the form
$form.Controls.Add($pictureBox)

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
