const Exchange = artifacts.require("./Exchange.sol")
const Token = artifacts.require("./Token.sol")

contract('Exchange.submitOrder() && executeOrder()', accounts => {
  const maker = accounts[0]
  const taker = accounts[1]
  let orderId
  let exchange
  let token

  it("submitOrder(), should succeed by adding a new order to the orderBook on-chain.", async () => {
    exchange = await Exchange.new()
    token = await Token.new({ from: maker });

    const bidToken = token.address
    const bidAmount = 1
    const askToken = 0
    const askAmount = 100

    await token.mint(maker, bidAmount, { from: maker });
    await token.approve(exchange.address, bidAmount, { from: maker })

    const tx = await exchange.submitOrder(bidToken, bidAmount, askToken, askAmount, {
        from: maker,
        gas : 4e6
      }
    )

    const log = tx.logs[0]
    assert.equal(log.event, 'LogOrderSubmitted', 'Event not emitted')

    orderId = tx.logs[0].args.id
    const order = await exchange.orderBook_(orderId)
    assert.equal(order[0], maker, 'maker incorrect')
    assert.equal(order[1], bidToken, 'bid token incorrect')
    assert.equal(order[2], bidAmount, 'bid amount incorrect')
    assert.equal(order[3], askToken, 'ask token incorrect')
    assert.equal(order[4], askAmount, 'ask amount incorrect')
  })

  it("executeOrder(), should succeed by trading the tokens. Maker bids ether.", async () => {
    /********************************
    * Get ETH balances before trade *
    ********************************/

    /********************
    * Execute the order *
    ********************/

    /*******************************
    * Confirm correct event logged *
    *******************************/


    /*********************************
    * Confirm token balances correct *
    *********************************/


    /*******************************
    * Confirm ETH balances correct *
    *******************************/


    /**************************
    * Confirm does not exist! *
    **************************/
    
  })
})
