require_relative '../../spec_helper'

module Brainy
  describe JMatrix do
    let (:mat_data) { [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]] }
    let (:vec_data) { [1.0, 2.0] }
    let (:mat) { JMatrix.new(mat_data) }
    let (:vec) { JMatrix.new(vec_data) }

    describe '.build' do
      it 'builds a new JMatrix' do
        built_mat = JMatrix.build(3, 2) { 0 }
        expect(built_mat).to be_a JMatrix
        expect(built_mat.rows).to eq 3
        expect(built_mat.columns).to eq 2
      end
    end

    describe '#*' do
      it 'returns a new matrix from matrix multiplication' do
        result = mat * vec
        expect(result.to_a).to eq [5.0, 11.0, 17.0]
      end
    end

    describe '#-' do
      it 'returns the difference between the two matrices' do
        result = JMatrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]) - JMatrix.new([[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]])
        expect(result.to_a).to eq [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0]]
      end
    end

    describe '#to_a' do
      it 'returns the matrix data as an array' do
        expect(mat.to_a).to eq mat_data
        expect(vec.to_a).to eq vec_data
      end
    end

    describe '#row_vectors' do
      it 'returns an array of row vectors' do
        expect(mat.row_vectors.map(&:to_a)).to eq mat_data
      end
    end
  end
end
