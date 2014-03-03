require "CSV"
require "pry"

class BankAccounts
  attr_accessor :account, :balance
  def initialize(account=nil, balance=0)
    @account      = account
    @balance      = balance
    @transactions = []
  end

  def starting_balance
    @balance
  end

  def ending_balance
    total = 0
    @transactions.each do |x|
     total += x.amount
   end
    @balance + total
  end

  def summary
    puts "==== #{@account} ===="
    puts "Starting Balance: #{make_money(starting_balance)}"
    puts "Ending Balance:   #{make_money(ending_balance)}"
    @transactions.each do |trans|
      puts trans.summary
    end
    puts "========"

  end

  def add_transaction(transaction)
    @transactions << transaction
  end
end


class BankTransaction
  attr_accessor :date, :amount, :description
  def initialize(date, amount, description)
    @date = date
    @amount = amount
    @description = description
  end

  def debit?
    @amount < 0
  end

  def credit?
    @amount > 0
  end

  def debt_or_credit?
    return "DEBIT" if debit?
    return "CREDIT" if credit?
  end

  def summary
    #$29.99   DEBIT  09/12/2013 - Amazon.com
    "$#{@amount}    #{debt_or_credit?} #{@date} - #{@description} "
  end
end


def make_money(number)
  sprintf("$%.2f",number.to_f)
end

purchasing = BankAccounts.new
business   = BankAccounts.new



CSV.foreach("balances.csv", headers: true, :header_converters => :symbol, :converters => :all) do |row|
  if row[:account]    == "Business Checking"
    business.account   = row[:account]
    business.balance   = row[:balance]
  elsif row[:account] == "Purchasing Account"
    purchasing.account = row[:account]
    purchasing.balance = row[:balance]
  end
end

CSV.foreach("bank_data.csv", headers: true, :header_converters => :symbol, :converters => :all) do |row|
  if row[:account]    == "Business Checking"
    business.add_transaction(BankTransaction.new(row[:date],row[:amount],row[:description]))
  elsif row[:account] == "Purchasing Account"
    purchasing.add_transaction(BankTransaction.new(row[:date],row[:amount],row[:description]))
  end
end




business.summary
purchasing.summary













