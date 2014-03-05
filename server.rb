

require "sinatra"
require "CSV"
require "pry"
require "shotgun"

class BankAccounts
  attr_reader :transactions, :starting_balance, :account, :balance
  def initialize(account, balance=0)
    @account          = account
    @balance          = balance
    @transactions     = []
    @starting_balance = balance
  end

  def summary
    summary_statement= ''
    summary_statement << "==== #{@account} ====\n"
    summary_statement << "Starting Balance: #{make_money(@starting_balance)}\n"
   summary_statement <<  "Ending Balance:   #{make_money(@balance)}\n"
    @transactions.each do |trans|
      summary_statement <<  "#{trans.summary}"
    end
    summary_statement << "========\n"
  end

  def add_transaction(transaction)
    @transactions << transaction
    @balance += transaction.amount
  end
end


class BankTransaction
  attr_accessor :date, :amount, :description
  def initialize(date, amount, description)
    @date        = date
    @amount      = amount
    @description = description
  end

  def debit?
    @amount < 0
  end

  def credit?
    @amount > 0
  end

  def debit_or_credit?

    return "DEBIT" if debit?
    return "CREDIT" if credit?
  end

  def summary
    #$29.99   DEBIT  09/12/2013 - Amazon.com
    "\t$#{@amount.abs}    \t#{debit_or_credit?} \t#{@date} - #{@description} \n"
  end
end


def make_money(number)
  sprintf("$%.2f",number.to_f)
end

bank = {}

CSV.foreach("balances.csv", headers: true, :header_converters => :symbol, :converters => :all) do |row|
  bank[row[:account]] = BankAccounts.new(row[:account], row[:balance])
end

CSV.foreach("bank_data.csv", headers: true, :header_converters => :symbol, :converters => :all) do |row|
  bank[row[:account]].add_transaction(BankTransaction.new(row[:date],row[:amount],row[:description]))
end

bank.each do |account, details|
  puts details.summary
end




get '/accounts/:accountName' do
  @accountName = params[:accountName].gsub "+", " "
  @account     = bank[@accountName]
  erb :bankinfo
end


set :views, File.dirname(__FILE__) + '/views'






























