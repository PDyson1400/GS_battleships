class Ship
    def initialize(length)
        @length = length
        @coord = []
    end

    def length
        return @length
    end

    def coadd(arr)
        @coord.push(arr)
    end

    def coord
        return @coord
    end

    def coclear
        @coord = []
    end
end