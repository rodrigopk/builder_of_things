describe Thing do
  @jane = Thing.new('Jane')
  
  describe 'jane = Thing.new("Jane")' do
    describe 'jane.name' do
      it 'should be "Jane"' do
        Test.assert_equals(@jane.name, 'Jane')
      end
    end
  end

  describe '#is_a' do
    describe 'is_a.woman (dynamic key)' do
      before { @jane.is_a.woman }
      it 'jane.woman? should return true' do
        Test.assert_equals(@jane.woman?, true)
      end
    end
  end

  describe '#is_not_a' do
    describe 'is_not_a.man (dynamic key)' do
      before { @jane.is_not_a.man }
      it 'jane.man? should return false' do
        Test.assert_equals(@jane.man?, false)
      end
    end
  end

  describe '#has' do
    describe 'jane.has(2).arms' do
      before do 
        @jane = Thing.new('Jane')
        @jane.has(2).arms
      end

      it 'should define an arms method that is an array' do
        Test.assert_equals(@jane.arms.is_a?(Array), true)
      end

      it 'should populate 2 new Thing instances within the array' do
        Test.assert_equals(@jane.arms.size, 2)
        Test.assert_equals(@jane.arms.all? {|v| v.is_a? Thing}, true)
      end

      it 'should call each thing by its singular form (aka "arm")' do
        Test.assert_equals(@jane.arms.first.name, "arm")
      end

      it 'should have arm? == true for each arm instance' do
        Test.assert_equals(@jane.arms.first.arm?, true)
      end
    end

    describe 'jane.having(2).arms (alias)' do
      it 'should populate 2 new Thing instances within the array' do
        @jane = Thing.new('Jane')
        @jane.having(2).arms
        Test.assert_equals(@jane.arms.size, 2)
        Test.assert_equals(@jane.arms.all? {|v| v.is_a? Thing}, true)
      end
    end

    describe 'jane.has(1).head' do
      before do 
        @jane = Thing.new('Jane')
        @jane.has(1).head
      end

      it 'should define head method that is a reference to a new Thing' do
        Test.assert_equals(@jane.head.is_a?(Thing), true)
      end

      it 'should name the head thing "head"' do
        Test.assert_equals(@jane.head.name, "head")
      end
    end

    describe 'jane.has(1).head.having(2).eyes' do
      before do 
        @jane = Thing.new('Jane')
        @jane.has(1).head.having(2).eyes
      end

      it 'should create 2 new things on the head' do
        Test.assert_equals(@jane.head.eyes.size, 2)
        Test.assert_equals(@jane.head.eyes.first.is_a?(Thing), true)
      end

      it 'should name the eye things "eye"' do
        Test.assert_equals(@jane.head.eyes.first.name, 'eye')
      end
    end
  end

  describe '#each' do
    describe 'jane.has(2).arms.each { having(5).fingers }' do
      before do 
        @jane = Thing.new('Jane')
        @jane.has(2).arms.each { having(5).fingers }
      end

      it 'should cause 2 arms to be created each with 5 fingers' do
        Test.assert_equals(@jane.arms.first.fingers.size, 5)
        Test.assert_equals(@jane.arms.last.fingers.size, 5)
      end
    end
  end

  describe '#is_the' do
    describe 'jane.is_the.parent_of.joe' do
      before do 
        @jane = Thing.new('Jane')
        @jane.is_the.parent_of.joe
      end

      it 'should set jane.parent_of == "joe"' do
        Test.assert_equals(@jane.parent_of, 'joe')
      end
    end

    describe 'ensure dynamic usages' do
      it 'should set any name and value (jane.is_the.???.????)' do
        @jane.is_the.mother_of.kate
        Test.assert_equals(@jane.mother_of, 'kate')

        @jane.is_the.master_of.karate
        Test.assert_equals(@jane.master_of, 'karate')
      end
    end
  end

  describe '#being_the' do
    describe 'jane.has(1).head.having(2).eyes.each { being_the.color.blue }' do
      it "jane's eyes should both be blue" do
        @jane = Thing.new('Jane')
        @jane.has(1).head.having(2).eyes.each { being_the.color.blue }
        Test.assert_equals(@jane.head.eyes.all? {|e| e.color == 'blue'}, true)
      end
    end

    describe 'jane.has(2).eyes.each { being_the.color.blue.and_the.shape.round }' do
      it 'should allow chaining via the and_the method' do
        @jane = Thing.new('Jane')
        @jane.has(2).eyes.each { being_the.color.blue.and_the.shape.round }
        Test.assert_equals(@jane.eyes.first.color, 'blue')
        Test.assert_equals(@jane.eyes.first.shape, 'round')
      end
    end

    describe 'jane.has(2).eyes.each { being_the.color.green.having(1).pupil.being_the.color.black }' do
      it 'should allow nesting by using having' do
        @jane = Thing.new('Jane')
        @jane.has(2).eyes.each { being_the.color.green.having(1).pupil.being_the.color.black }
        Test.assert_equals(@jane.eyes.first.color, 'green')
        Test.assert_equals(@jane.eyes.first.pupil.color, 'black')
      end
    end
  end

  describe '#can' do
    describe 'jane.can.speak {|phrase| "#{name} says: #{phrase}"}' do
      before do
        @jane = Thing.new('Jane')
        @jane.can.speak do |phrase|
          "#{name} says: #{phrase}"
        end
      end

      it 'should create a speak method on the instance' do
        Test.assert_equals(@jane.speak('hi'), "Jane says: hi")
      end

    end
    describe 'jane.can.speak("spoke") {|phrase| "#{name} says: #{phrase}"}' do
      before do
        @jane = Thing.new('Jane')
        @jane.can.speak('spoke') { |phrase| "#{name} says: #{phrase}" }

        @jane.speak('hi')
      end

      it 'should add a "spoke" attribute that tracks all speak call results' do
        Test.assert_equals(@jane.spoke, ["Jane says: hi"])
        @jane.speak('goodbye')
        Test.assert_equals(@jane.spoke, ["Jane says: hi", "Jane says: goodbye"])
      end
    end
  end
end