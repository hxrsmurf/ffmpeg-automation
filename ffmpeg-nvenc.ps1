# Download and extract the latest FFmpeg Windows build from https://github.com/BtbN/FFmpeg-Builds/releases
$ffmpeg_nvenc = ""

$base_folder = ""
$log = $base_folder + (Get-Date -Format "yyyy-MM-dd") + ".log"
$output = $base_folder + "\hls\"

$episodes = Get-ChildItem $base_folder -Name
$season = "S01"
$extension = ".m3u8"

foreach ($episode in $episodes) {
    if ($episode -eq "hls") { continue }

    $import_episode = $base_folder + $episode
    $split_episode = "E" + $episode.split('_')[4]
    $full_episode_name = $season + $split_episode

    $full_output_path = $output + $full_episode_name + "\"
    $output_file = $full_output_path + $full_episode_name + $extension

    if (!(Test-Path $full_output_path)) {
        mkdir $full_output_path
    }

    if ($full_episode_name -like "S01E*") {
        if (!(Test-Path $output_file)) {
            Add-Content (Get-Date -Format ("yyyy-MM-dd HH:mm:ss")) -Path $log
            Add-Content "Write-Host Converting $import_episode" -Path $log

            . $ffmpeg_nvenc -hwaccel cuda -hwaccel_output_format cuda `
                -i $import_episode `
                -c:a copy -c:v h264_nvenc `
                -b:v 512K `
                -flags +cgop -g 30 `
                -hls_time 1 `
                -hls_playlist_type event `
                $output_file
            
            Add-Content(Get-Date -Format ("yyyy-MM-dd HH:mm:ss")) -Path $log
            Add-Content "Completed $full_episode_name" -Path $log
        } else {
            Add-Content "Already Completed $full_episode_name" -Path $log
            Write-Host "Already completed $full_episode_name"
        }
    }
}
