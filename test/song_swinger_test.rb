require 'includes'

class SongSwingerTest < Test::Unit::TestCase
  def test_full_song_swing_rate_8
    base_path = File.dirname(__FILE__) + "/sounds"
    song, kit = SongParser.new.parse(base_path, File.read("test/fixtures/valid/example_mono_16_base_path.txt"))

    shuffled_song = Transforms::SongSwinger.transform(song, 8)

    assert_equal(180, shuffled_song.tempo)
    assert_equal([:verse, :verse, :chorus, :chorus, :chorus, :chorus,
                  :verse, :verse, :chorus, :chorus, :chorus, :chorus],
                 shuffled_song.flow)

    assert_equal([:chorus, :verse], shuffled_song.patterns.keys.sort)

    chorus_pattern = shuffled_song.patterns[:chorus]
    assert_equal(["bass",
                  "snare",
                  "hh_closed",
                  "hh_closed2",
                  "tom4_mono_16.wav",
                  "tom2_mono_16.wav"],
                 chorus_pattern.tracks.keys)

    assert_equal("X.....X.....X.X...X.....", chorus_pattern.tracks["bass"].rhythm)
    assert_equal("......X...........X.....", chorus_pattern.tracks["snare"].rhythm)
    assert_equal("X...XXX...XX............", chorus_pattern.tracks["hh_closed"].rhythm)
    assert_equal("............X...XX....X.", chorus_pattern.tracks["hh_closed2"].rhythm)
    assert_equal(".................X......", chorus_pattern.tracks["tom4_mono_16.wav"].rhythm)
    assert_equal("......................X.", chorus_pattern.tracks["tom2_mono_16.wav"].rhythm)

    verse_pattern = shuffled_song.patterns[:verse]
    assert_equal(["bass",
                  "snare",
                  "hh_closed",
                  "hh_closed2",
                  "agogo"],
                 verse_pattern.tracks.keys)

    assert_equal("X.....X.....X.....X.....", verse_pattern.tracks["bass"].rhythm)
    assert_equal("......................X.", verse_pattern.tracks["snare"].rhythm)
    assert_equal("X...XXX...XX............", verse_pattern.tracks["hh_closed"].rhythm)
    assert_equal("............X...X.X...X.", verse_pattern.tracks["hh_closed2"].rhythm)
    assert_equal("......................XX", verse_pattern.tracks["agogo"].rhythm)
  end

  def test_full_song_swing_rate_16
    base_path = File.dirname(__FILE__) + "/sounds"
    song, kit = SongParser.new.parse(base_path, File.read("test/fixtures/valid/example_mono_16_base_path.txt"))

    shuffled_song = Transforms::SongSwinger.transform(song, 16)

    assert_equal(180, shuffled_song.tempo)
    assert_equal([:verse, :verse, :chorus, :chorus, :chorus, :chorus,
                  :verse, :verse, :chorus, :chorus, :chorus, :chorus],
                 shuffled_song.flow)

    assert_equal([:chorus, :verse], shuffled_song.patterns.keys.sort)

    chorus_pattern = shuffled_song.patterns[:chorus]
    assert_equal(["bass",
                  "snare",
                  "hh_closed",
                  "hh_closed2",
                  "tom4_mono_16.wav",
                  "tom2_mono_16.wav"],
                 chorus_pattern.tracks.keys)

    assert_equal("X.....X.....X.X...X.....", chorus_pattern.tracks["bass"].rhythm)
    assert_equal("......X...........X.....", chorus_pattern.tracks["snare"].rhythm)
    assert_equal("X..X.XX..X.X............", chorus_pattern.tracks["hh_closed"].rhythm)
    assert_equal("............X..X.X...X..", chorus_pattern.tracks["hh_closed2"].rhythm)
    assert_equal(".................X......", chorus_pattern.tracks["tom4_mono_16.wav"].rhythm)
    assert_equal(".....................X..", chorus_pattern.tracks["tom2_mono_16.wav"].rhythm)

    verse_pattern = shuffled_song.patterns[:verse]
    assert_equal(["bass",
                  "snare",
                  "hh_closed",
                  "hh_closed2",
                  "agogo"],
                 verse_pattern.tracks.keys)

    assert_equal("X.....X.....X.....X.....", verse_pattern.tracks["bass"].rhythm)
    assert_equal(".....................X..", verse_pattern.tracks["snare"].rhythm)
    assert_equal("X..X.XX..X.X............", verse_pattern.tracks["hh_closed"].rhythm)
    assert_equal("............X..X..X..X..", verse_pattern.tracks["hh_closed2"].rhythm)
    assert_equal(".....................X.X", verse_pattern.tracks["agogo"].rhythm)
  end

  def test_odd_pattern_length
    song = Song.new

    pattern = song.pattern(:my_pattern)
    pattern.track("track1", "X..X..X")

    song.pattern(pattern)

    shuffled_song = Transforms::SongSwinger.transform(song, 16)
    shuffled_pattern = shuffled_song.patterns[:my_pattern]
    assert_equal("X....X...X", shuffled_pattern.tracks["track1"].rhythm)
  end

  def test_swing_8_conversions
    [["XXXXX.X.", "X.X.XXX...X."],
     ["XXXXXXX",  "X.X.XXX.X.X"],
     ["XXXX",     "X.X.XX"],
     ["....",     "......"],
     ["XXX",      "X.X.X"],
     ["XX",       "X.X."],
     ["X",        "X."]].each do |original_rhythm, expected_rhythm|
      song = Song.new

      pattern = song.pattern(:my_pattern)
      pattern.track("track1", original_rhythm)

      song.pattern(pattern)

      shuffled_song = Transforms::SongSwinger.transform(song, 8)
      shuffled_pattern = shuffled_song.patterns[:my_pattern]
      assert_equal(expected_rhythm, shuffled_pattern.tracks["track1"].rhythm)
    end
  end

  def test_fractional_tempo_rounded_up
    [8, 16].each do |swing_rate|
      song = Song.new
      song.tempo = 140

      song = Transforms::SongSwinger.transform(song, swing_rate)
      assert_equal(210, song.tempo)
    end
  end

  def test_fractional_tempo_rounded_down
    [8, 16].each do |swing_rate|
      song = Song.new
      song.tempo = 145

      song = Transforms::SongSwinger.transform(song, 16)
      assert_equal(218, song.tempo)   # 217.5 rounded up
    end
  end
end
