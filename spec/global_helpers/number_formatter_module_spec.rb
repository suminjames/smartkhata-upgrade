require 'rails_helper'

RSpec.describe NumberFormatterModule, type: :helper do
  let(:dummy_class) { Class.new { extend NumberFormatterModule } }

  describe '.arabic_word' do
    it 'should convert number' do
      expect(dummy_class.arabic_word(333.33)).to eq('Three Hundred And Thirty Three Rupees And 33/100')
    end
  end

  describe '.arabic_number' do
    context 'when decimal number present' do
      it 'should return amount' do
        expect(dummy_class.arabic_number(45.677)).to eq('45.68')
      end
    end

    context 'when decimal number not present' do
      it 'should return zero' do
        expect(dummy_class.arabic_number(nil)).to eq('0.00')
      end
    end

    context 'when decimal number is negative' do
      it 'should return negative amount' do
        expect(dummy_class.arabic_number(-45.677)).to eq('-45.68')
      end
    end

  end

  describe '.monetary_decimal' do
    it 'should return value' do
      expect(dummy_class.monetary_decimal(5.678)).to eq('5.68')
    end
  end

  describe '.arabic_number_integer' do
    it 'should return value before decimal point' do
      expect(dummy_class.arabic_number_integer(67.45545)).to eq('67')
    end
  end

  describe '.strip_redundant_decimal_zeroes' do
    it 'should strip redundant decimal zeros' do
      expect(dummy_class.strip_redundant_decimal_zeroes(76.500)).to eq(76.5)
    end
  end
end
