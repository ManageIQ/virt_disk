require "spec_helper"
require "virt_disk"

def new_test_class(cname, methods_exported = [], methods_not_exported = [])
  klass = Class.new { include VirtDisk::ExportMethods }
  stub_const cname, klass
  add_test_methods(klass, methods_exported, methods_not_exported)
  klass
end

def add_test_methods(klass, methods_exported, methods_not_exported)
  klass.class_eval do
    (methods_exported + methods_not_exported).each do |mn|
      define_method(mn) { "In #{self.class.name}##{mn}" }
    end
    export(*methods_exported)
  end
end

describe VirtDisk::ExportMethods do
  let(:group_a_methods) do
    %i( method1 method2 method3 )
  end

  let(:group_b_methods) do
    %i( method4 method5 method6 )
  end

  let(:group_c_methods) do
    %i( method7 )
  end

  describe "defined methods" do
    before(:each) do
      new_test_class('TestMod1')
    end

    describe "Class methods" do
      it "should respond to export" do
        expect(TestMod1.respond_to?(:export)).to be true
      end

      it "should respond to exports" do
        expect(TestMod1.respond_to?(:exports)).to be true
      end

      it "should respond to exported?" do
        expect(TestMod1.respond_to?(:exported?)).to be true
      end
    end

    describe "Instance methods" do
      let(:mod1_obj) { TestMod1.new }

      it "should respond to exported?" do
        expect(mod1_obj.respond_to?(:exported?)).to be true
      end

      it "should respond to delegate=" do
        expect(mod1_obj.respond_to?(:delegate=)).to be true
      end

      it "should respond to delegate" do
        expect(mod1_obj.respond_to?(:delegate)).to be true
      end
    end
  end

  describe "Class methods" do
    describe "export" do
      before(:each) do
        new_test_class('TestMod1', group_a_methods, group_c_methods)
      end

      it "should raise an error when method isn't defined" do
        expect do
          TestMod1.export(:foo)
        end.to raise_exception(RuntimeError, "Method not defined in class: foo")
      end

      it "should return nil on success" do
        expect(TestMod1.export(group_c_methods.first)).to be_nil
      end

      it "should add the method to the exports list" do
        meth = group_c_methods.first
        expect(TestMod1.exports.include?(meth)).to be false
        TestMod1.export(meth)
        expect(TestMod1.exports.include?(meth)).to be true
      end
    end

    describe "exports" do
      before(:each) do
        new_test_class('TestMod1', [], group_a_methods)
      end

      it "should return an empty array when nothing exported" do
        expect(TestMod1.exports).to match_array([])
      end

      it "should return the expected array" do
        expect(TestMod1.exports).to match_array([])
        TestMod1.export(*group_a_methods)
        expect(TestMod1.exports).to match_array(group_a_methods)
      end
    end

    describe "exported?" do
      before(:each) do
        new_test_class('TestMod1', [], group_a_methods)
      end

      it "should return false when nothing exported" do
        expect(TestMod1.exported?(group_a_methods.first)).to be false
      end

      it "should return false when method isn't exported" do
        TestMod1.export(*group_a_methods)
        expect(TestMod1.exported?(group_b_methods.first)).to be false
      end

      it "should return true when method is exported" do
        TestMod1.export(*group_a_methods)
        expect(TestMod1.exported?(group_a_methods.first)).to be true
      end
    end
  end

  describe "Instance methods" do
    let(:no_export_obj) do
      new_test_class('NoExportMod')
      NoExportMod.new
    end

    let(:export_obj) do
      new_test_class('ExportMod', group_a_methods)
      ExportMod.new
    end

    describe "exported?" do
      it "should return false when nothing exported" do
        expect(no_export_obj.exported?(group_a_methods.first)).to be false
      end

      it "should return false when method isn't exported" do
        expect(export_obj.exported?(group_b_methods.first)).to be false
      end

      it "should return true when method is exported" do
        expect(export_obj.exported?(group_a_methods.first)).to be true
      end
    end

    describe "delegate, delegate=" do
      it "should return nil when no delegate" do
        expect(no_export_obj.delegate).to be nil
      end

      it "should return the object it is passed" do
        expect(no_export_obj.delegate = export_obj).to eq(export_obj)
      end

      it "should set the delegate accordingly" do
        no_export_obj.delegate = export_obj
        expect(no_export_obj.delegate).to eq(export_obj)
      end
    end
  end

  describe "Operation" do
    let(:obja) do
      new_test_class('ModA', group_a_methods)
      ModA.new
    end

    let(:objb) do
      new_test_class('ModB', group_b_methods)
      ModB.new
    end

    let(:objc) do
      new_test_class('ModC', group_c_methods)
      ModC.new
    end

    it "should 'respond_to?' top-level methods" do
      expect(obja.respond_to?(group_a_methods.first)).to eq true
    end

    it "should call top-level methods directly" do
      method_name = group_a_methods.first
      expect(obja.send(method_name)).to eq("In #{obja.class.name}##{method_name}")
    end

    it "should 'respond_to?' 2nd-level methods" do
      expect(obja.respond_to?(group_a_methods.first)).to eq true
      expect(obja.respond_to?(group_b_methods.first)).to eq false

      obja.delegate = objb
      expect(obja.respond_to?(group_b_methods.first)).to eq true
    end

    it "should call 2nd-level methods" do
      method_a_name = group_a_methods.first
      method_b_name = group_b_methods.first

      expect(obja.send(method_a_name)).to eq("In #{obja.class.name}##{method_a_name}")

      expect do
        obja.send(method_b_name)
      end.to raise_exception(NoMethodError, /undefined method `#{method_b_name}' for.*/)

      obja.delegate = objb
      expect(obja.send(method_b_name)).to eq("In #{objb.class.name}##{method_b_name}")
    end

    it "should 'respond_to?' 3rd-level methods" do
      expect(obja.respond_to?(group_a_methods.first)).to eq true
      expect(obja.respond_to?(group_b_methods.first)).to eq false
      expect(obja.respond_to?(group_c_methods.first)).to eq false

      obja.delegate = objb
      expect(obja.respond_to?(group_b_methods.first)).to eq true
      expect(obja.respond_to?(group_c_methods.first)).to eq false

      objb.delegate = objc
      expect(obja.respond_to?(group_c_methods.first)).to eq true
    end

    it "should call 3rd-level methods" do
      method_a_name = group_a_methods.first
      method_b_name = group_b_methods.first
      method_c_name = group_c_methods.first

      expect(obja.send(method_a_name)).to eq("In #{obja.class.name}##{method_a_name}")

      expect do
        obja.send(method_b_name)
      end.to raise_exception(NoMethodError, /undefined method `#{method_b_name}' for.*/)

      expect do
        obja.send(method_c_name)
      end.to raise_exception(NoMethodError, /undefined method `#{method_c_name}' for.*/)

      obja.delegate = objb
      expect(obja.send(method_b_name)).to eq("In #{objb.class.name}##{method_b_name}")

      expect do
        obja.send(method_c_name)
      end.to raise_exception(NoMethodError, /undefined method `#{method_c_name}' for.*/)

      objb.delegate = objc
      expect(obja.send(method_c_name)).to eq("In #{objc.class.name}##{method_c_name}")
    end
  end
end
