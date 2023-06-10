namespace TestWMIEvent
{
    partial class FrmMain
    {
        /// <summary>
        /// Variable nécessaire au concepteur.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Nettoyage des ressources utilisées.
        /// </summary>
        /// <param name="disposing">true si les ressources managées doivent être supprimées ; sinon, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Code généré par le Concepteur Windows Form

        /// <summary>
        /// Méthode requise pour la prise en charge du concepteur - ne modifiez pas
        /// le contenu de cette méthode avec l'éditeur de code.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnStopProcess = new System.Windows.Forms.Button();
            this.btnStartProcess = new System.Windows.Forms.Button();
            this.btnStopAllWatching = new System.Windows.Forms.Button();
            this.btnRunProcess = new System.Windows.Forms.Button();
            this.btnCreateNewFile = new System.Windows.Forms.Button();
            this.btnClose = new System.Windows.Forms.Button();
            this.btnUnknownEvent = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnStopProcess
            // 
            this.btnStopProcess.Location = new System.Drawing.Point(13, 13);
            this.btnStopProcess.Name = "btnStopProcess";
            this.btnStopProcess.Size = new System.Drawing.Size(175, 23);
            this.btnStopProcess.TabIndex = 0;
            this.btnStopProcess.Text = "Arrêt surveillance process";
            this.btnStopProcess.UseVisualStyleBackColor = true;
            this.btnStopProcess.Click += new System.EventHandler(this.btnStopProcess_Click);
            // 
            // btnStartProcess
            // 
            this.btnStartProcess.Location = new System.Drawing.Point(13, 52);
            this.btnStartProcess.Name = "btnStartProcess";
            this.btnStartProcess.Size = new System.Drawing.Size(175, 23);
            this.btnStartProcess.TabIndex = 1;
            this.btnStartProcess.Text = "Démarrage surveillance process";
            this.btnStartProcess.UseVisualStyleBackColor = true;
            this.btnStartProcess.Click += new System.EventHandler(this.btnStartProcess_Click);
            // 
            // btnStopAllWatching
            // 
            this.btnStopAllWatching.Location = new System.Drawing.Point(12, 98);
            this.btnStopAllWatching.Name = "btnStopAllWatching";
            this.btnStopAllWatching.Size = new System.Drawing.Size(175, 23);
            this.btnStopAllWatching.TabIndex = 2;
            this.btnStopAllWatching.Text = "Arrêt de toutes les surveillances";
            this.btnStopAllWatching.UseVisualStyleBackColor = true;
            this.btnStopAllWatching.Click += new System.EventHandler(this.btnStopAllWatching_Click);
            // 
            // btnRunProcess
            // 
            this.btnRunProcess.Location = new System.Drawing.Point(254, 12);
            this.btnRunProcess.Name = "btnRunProcess";
            this.btnRunProcess.Size = new System.Drawing.Size(173, 23);
            this.btnRunProcess.TabIndex = 3;
            this.btnRunProcess.Text = "Nouvelle instance Notepad";
            this.btnRunProcess.UseVisualStyleBackColor = true;
            this.btnRunProcess.Click += new System.EventHandler(this.btnRunProcess_Click);
            // 
            // btnCreateNewFile
            // 
            this.btnCreateNewFile.Location = new System.Drawing.Point(254, 52);
            this.btnCreateNewFile.Name = "btnCreateNewFile";
            this.btnCreateNewFile.Size = new System.Drawing.Size(173, 23);
            this.btnCreateNewFile.TabIndex = 4;
            this.btnCreateNewFile.Text = "Nouveau fichier";
            this.btnCreateNewFile.UseVisualStyleBackColor = true;
            this.btnCreateNewFile.Click += new System.EventHandler(this.btnCreateNewFile_Click);
            // 
            // btnClose
            // 
            this.btnClose.Location = new System.Drawing.Point(352, 162);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(75, 23);
            this.btnClose.TabIndex = 5;
            this.btnClose.Text = "Fermer";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // btnUnknownEvent
            // 
            this.btnUnknownEvent.Location = new System.Drawing.Point(12, 141);
            this.btnUnknownEvent.Name = "btnUnknownEvent";
            this.btnUnknownEvent.Size = new System.Drawing.Size(175, 23);
            this.btnUnknownEvent.TabIndex = 6;
            this.btnUnknownEvent.Text = "Emet un événement inconnu";
            this.btnUnknownEvent.UseVisualStyleBackColor = true;
            this.btnUnknownEvent.Click += new System.EventHandler(this.btnUnknownEvent_Click);
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(450, 197);
            this.Controls.Add(this.btnUnknownEvent);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.btnCreateNewFile);
            this.Controls.Add(this.btnRunProcess);
            this.Controls.Add(this.btnStopAllWatching);
            this.Controls.Add(this.btnStartProcess);
            this.Controls.Add(this.btnStopProcess);
            this.Name = "FrmMain";
            this.Text = "Tests WMIEvent";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnStopProcess;
        private System.Windows.Forms.Button btnStartProcess;
        private System.Windows.Forms.Button btnStopAllWatching;
        private System.Windows.Forms.Button btnRunProcess;
        private System.Windows.Forms.Button btnCreateNewFile;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.Button btnUnknownEvent;
    }
}

