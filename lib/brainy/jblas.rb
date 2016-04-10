module Brainy
  java_import org.jblas.DoubleMatrix

  class JMatrix
    attr_accessor :java_matrix

    def initialize(data)
      if data.is_a?(DoubleMatrix)
        @java_matrix = data
      elsif data.first.is_a?(Array)
        @java_matrix = DoubleMatrix.new(data.to_java(Java::double[]))
      else
        @java_matrix = DoubleMatrix.new(data.to_java(Java::double))
      end
    end

    def self.build(row_count, column_count, &block) #TODO refactor for performance (!!!)
      JMatrix.new(row_count.times.map do |row|
        column_count.times.map { |col| block.yield(row, col) }
      end)
    end

    def *(mat)
      JMatrix.new(@java_matrix.mmul(mat.java_matrix))
    end

    def -(mat)
      JMatrix.new(@java_matrix.sub(mat.java_matrix))
    end

    def to_a
      return @java_matrix.getRow(0).toArray.to_a if rows == 1
      return @java_matrix.getColumn(0).toArray.to_a if columns == 1
      @java_matrix.rowsAsList.toArray.map { |row| row.toArray.to_a }
    end

    def row_vectors
      @java_matrix.rowsAsList.toArray.map { |row| JMatrix.new(row) }
    end

    def rows
      @java_matrix.rows
    end

    def columns
      @java_matrix.columns
    end

    def map(&block)
      return to_a.map { |a| a.to_a.map(&block) } if to_a.first.is_a?(Array)
      to_a.map(&block)
    end

    def each_with_index(&block)
      to_a.each_with_index(&block)
    end

    def [](idx)
      @java_matrix.get(idx)
    end
  end
end
