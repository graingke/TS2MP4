$inProcessPath = "C:\Users\Public\Recorded TV\"
do
{
        $oldVideos = Get-ChildItem -Include @("*.ts") -Path $inProcessPath -Recurse;

        #
        # START OF DELAY SECTION:  Delay Start Until 5 Minutes After Last .ts File Is Modified
        #
        $timerdone= 0
        do
        {
            foreach ($oldVideo in $oldVideos)
            {
                if ($LastVideo.lastwritetime -lt $oldvideo.LastWriteTime)
                    {
                        $LastVideo=$oldVideo
                    };
            };
            $x =$LastVideo.LastWriteTime.AddMinutes(5);
            $now = Get-Date;
            if  ($now.Subtract($x).TotalMinutes -lt 0)
            {
                $SecondsToGo = $x.Subtract($now).TotalSeconds;
                Start-Sleep -Seconds $SecondsToGo;        
                $timerdone = 0;
            }
            else
            {
                write-host Exiting;
                $timerdone=1;
            }    
        }
        while ($timerdone=0)
        #
        # END OF DELAY SECTION
        #
        $oldVideos = Get-ChildItem -Include @("*.ts") -Path $inProcessPath -Recurse;

        Set-Location -Path 'C:\Users\Public\Recorded TV\';
        #
        # PROCESS Each .ts File
        #
        foreach ($oldVideo in $oldVideos) 
        {    

            $newVideo = [io.path]::ChangeExtension($oldVideo.FullName, '.mp4')

            If (Test-Path $newVideo)
            {
                remove-item $oldVideo;     
            }
            Else  
            {
                # Declare the command line arguments for ffmpeg.exe
                $ArgumentList = '-i "{0}" -y -async 1 -b 2000k -ar 44100 -ac 2 -v 0 -f mp4 -vcodec libx264 "{1}"' -f $oldVideo, $newVideo;

                # Display the command line arguments, for validation
                date
                Write-Host -ForegroundColor Green -Object $ArgumentList;
                # Pause the script until user hits enter
                # $null = Read-Host -Prompt 'Press enter to continue, after verifying command line arguments.';
    
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = "C:\Users\Kent\Downloads\ffmpeg-20150421-git-a924b83-win64-static\bin\ffmpeg.exe"
                $pinfo.RedirectStandardError = $true
                $pinfo.RedirectStandardOutput = $true
                $pinfo.UseShellExecute = $false
                $pinfo.Arguments = $ArgumentList
                $p = New-Object System.Diagnostics.Process
                $p.StartInfo = $pinfo
                $p.Start() | Out-Null
                $p.WaitForExit()
                $stdout = $p.StandardOutput.ReadToEnd()
                $stderr = $p.StandardError.ReadToEnd()
                Write-Host "stdout: $stdout"
                Write-Host "stderr: $stderr"
                if ($p.ExitCode -eq 0)
                        {
                        Remove-item $oldvideo
                        };  
              };          
        $timerdone=0;
        date
        }
        start-sleep -seconds 300
}
while ($timerdone=0)