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
        expect(result.to_a).to eq [[5], [11], [17]]
      end
    end

    describe '#to_a' do
      it 'returns the matrix data as an array' do
        expect(mat.to_a).to eq mat_data
        expect(vec.to_a.flatten).to eq vec_data
      end
    end

    describe '#rows' do
      it 'returns the row count' do
        expect(mat.rows).to eq 3
      end
    end

    describe '#columns' do
      it 'returns the column count' do
        expect(mat.columns).to eq 2
      end
    end
  end
end
