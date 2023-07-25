# Squeezelite

# Any switches to pass to Squeezelite. See 'squeezelite -h' for a # description
# of all possible switches.

SQUEEZELITE_OPTS="-o iec958 -n Squeezelite-$(hostname) -D -c flac,pcm,mp3 -r 44100,48000,88200,96000,176400,192000 -a 80::16:1 -P 90"

# IMPORTANT INFORMATION:
#
# 1. Specify a specific audio device (such as the S/PDIF output above) to allow
# high bitrates. The default ALSA device is typically a mixer device that
# limits output to 48KHz max.
#
# 2. The -c option is used to specify formats that are supported by the player.
# Please note that they are LISTED IN ORDER OF PREFERENCE. It is important to
# LIST FLAC BEFORE PCM or Logitech Media Server will transcode your FLAC music
# to PCM, using unnecessary network bandwidth and LMS processing power.
#
# 3. The -D option enabled DSD/DOP/SACD support. In order for this to work, you
# will need to enable the 'DSDPlay' or similar plugin within Logitech Media
# Server and restart LMS.
#
# 4. Squeezelite will auto-discover your Logitech Media Server. To manually
# specify an IP address, use the -s <server>[:<port>] option.
#
# Enjoy!
#
# -Daniel Robbins
