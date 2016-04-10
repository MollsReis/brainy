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

    def to_a #TODO refactor this for performance?
      return columns.times.map { |col| @java_matrix.get(0, col) } if rows == 1
      return rows.times.map { |row| @java_matrix.get(row, 0) } if columns == 1
      rows.times.map do |row|
        columns.times.map { |col| @java_matrix.get(row, col) }
      end
    end

    def row_vectors
      rows.times.map { |row| JMatrix.new(@java_matrix.getRow(row)) }
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
      return @java_matrix.get(0, idx) if rows == 1
      return @java_matrix.get(idx, 0) if columns == 1
      to_a[idx]
    end
  end
end
