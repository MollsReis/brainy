module Brainy
  java_import org.jblas.DoubleMatrix

  class JMatrix
    attr_accessor :java_matrix

    def initialize(data)
      data_type = data.first.is_a?(Array) ? Java::double[] : Java::double
      @java_matrix = DoubleMatrix.new(data.to_java(data_type))
    end

    def self.build(row_count, col_count, &block)
      JMatrix.new(Array.new(row_count) { Array.new(col_count, &block) })
    end

    def self.from_java(matrix)
      new_jmat = JMatrix.new([[]])
      new_jmat.java_matrix = matrix
      new_jmat
    end

    def *(mat)
      JMatrix.from_java(@java_matrix.mmul(mat.java_matrix))
    end

    def to_a
      return columns.times.map { |col| @java_matrix.get(0, col) } if rows == 1
      return rows.times.map { |row| @java_matrix.get(row, 0) } if columns == 1
      rows.times.map do |row|
        columns.times.map { |col| @java_matrix.get(row, col) }
      end
    end

    def row_vectors
      rows.times.map { |row| JMatrix.from_java(@java_matrix.getRow(row)) }
    end

    def rows
      @java_matrix.rows
    end

    def columns
      @java_matrix.columns
    end

    def map(&block)
      return to_a.map { |a| a.to_a.map(&block) } if to_a.first.is_a? Array
      to_a.map(&block)
    end

    def each_with_index(&block)
      to_a.each_with_index(&block)
    end

    def [](idx)
      to_a[idx]
    end
  end
end
