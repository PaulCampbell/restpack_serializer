require './spec/spec_helper'

describe RestPack::Serializer::SideLoading do
  context "when side-loading" do
    describe ".belongs_to" do

      before(:each) do
        FactoryGirl.create(:artist_with_albums, album_count: 2)
        FactoryGirl.create(:artist_with_albums, album_count: 1)
      end
      let(:side_loads) { SongSerializer.side_loads(models, options) }

      context "with no models" do
        let(:models) { [] }

        context "no side-loads" do
          let(:options) { RestPack::Serializer::Options.new(Song) }

          it "returns a hash with no data" do
            side_loads.should == { :meta => {} }
          end
        end

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(Song, { "includes" => "albums" }) }

          it "returns a hash with no data" do
            side_loads.should == { :meta => {} }
          end
        end
      end

      context "with a single model" do
        let(:models) { [Song.first] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(Song, { "includes" => "albums" }) }

          it "returns side-loaded albums" do
            side_loads.should == {
              albums: [AlbumSerializer.as_json(Song.first.album)],
              meta: { }
            }
          end
        end
      end

      context "with multiple models" do
        let(:artist1) { Artist.find(1) }
        let(:artist2) { Artist.find(2) }
        let(:song1) { artist1.songs.first }
        let(:song2) { artist2.songs.first }
        let(:models) { [song1, song2] }

        context "when including :albums" do
          let(:options) { RestPack::Serializer::Options.new(Song, { "includes" => "albums" }) }

          it "returns side-loaded albums" do
            side_loads.should == {
              albums: [
                AlbumSerializer.as_json(song1.album),
                AlbumSerializer.as_json(song2.album)
              ],
              :meta => { }
            }
          end
        end
      end

    end
  end
end
