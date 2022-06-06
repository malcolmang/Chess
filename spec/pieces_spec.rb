require "spec_helper"
require_relative "../lib/pieces"
describe "#translateposition" do
  it "translates position diagonally" do
    piece = Piece.new("e4", "white")
    expect(piece.translateposition('e4',1,1)).to eql('f5')
  end

  it "tests out of bounds" do
    piece = Piece.new("h1", "white")
    expect(piece.translateposition('h1',1,1)).to eql(nil)
  end

  it "tests knight moving" do
    piece = Piece.new("e4", "white")
    expect(piece.translateposition('e4',-1,2)).to eql('d6')
  end
end 