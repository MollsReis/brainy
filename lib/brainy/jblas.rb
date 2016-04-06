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
      rows.times.map do |row|
        columns.times.map { |col| @java_matrix.get(row, col) }
      end
    end

    def rows
      @java_matrix.rows
    end

    def columns
      @java_matrix.columns
    end
  end
end
