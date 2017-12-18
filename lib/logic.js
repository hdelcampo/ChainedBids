'use strict';
/**
 * System transactions
 */

/**
 * Publish a product for auction
 * @param {es.uva.asai.chainedbids.AuctionStart} auctionStart - The auction announcement
 * @transaction
 */
function publishProductForAuction(auctionStart) {
    var product = auctionStart.product;
    if (product.state !== 'PUBLISHED') {
        throw new Error('Product cannot be for sale');
    }

    product.bestOffer = null;
    product.initialPrice = auctionStart.startingPrice;
    product.state = 'FOR_AUCTION';

    return getAssetRegistry('es.uva.asai.chainedbids.Product')
       .then(function(productRegistry) {
           return productRegistry.update(product);
       });
}

/** Make an Offer for a Product
 * @param {es.uva.asai.chainedbids.Offer} offer - the offer
 * @transaction
 */
function makeOffer(offer) {
   var product = offer.product;
   if (product.state !== 'FOR_AUCTION') {
       throw new Error('Product is not for sale');
   }

   if (offer.bidPrice < product.initialPrice) {
       throw new Error('New bid is too low')
   } else if (product.bestOffer && 
        product.bestOffer.bidPrice >= offer.bidPrice) {
       throw new Error('New bid is too low')
   }
   
   product.bestOffer = offer;

   return getAssetRegistry('es.uva.asai.chainedbids.Product')
       .then(function(productRegistry) {
           return productRegistry.update(product);
       });
}

/** Finish a product action
 * @param {es.uva.asai.chainedbids.AuctionFinish} auctionFinish - the finish notification
 * @transaction
 */
function finishAuction(auctionFinish) {
   var product = auctionFinish.product;
   if (product.state !== 'FOR_AUCTION') {
       throw new Error('Product is not for sale');
   }

   if (!product.bestOffer) {
       product.state = 'PRICE_NOT_MET';
   } else {
       product.state = 'SOLD';
   }

   return getAssetRegistry('es.uva.asai.chainedbids.Product')
        .then(function(productRegistry) {
            return productRegistry.update(product);
        });
}

/** Pay for a product, either return or selling
 * @param {es.uva.asai.chainedbids.Payment} payment - the payment
 * @transaction
 */
function pay(payment) {
    var product = payment.product;

    if (payment.type === 'NORMAL' &&
            product.state !== 'SOLD') {
        throw new Error('Product has not been sold');
    } else if (payment.type === 'RETURN' &&
                product.state !== 'TO_RETURN') {
        throw new Error('Product has not any issue');
    }

    if (payment.gateway.type !== 'PAYMENT_GATEWAY') {
        throw new Error('Only payment gateways can manage payments');
    }

    var origin = null;
    var destiny = null;
    var finalState = null;
 
    if (payment.type === 'NORMAL') {
        origin = product.seller;
        destiny = product.bestOffer.bidder;
        finalState = 'PAID';
    } else {
        origin = product.bestOffer.bidder;
        destiny = product.seller;
        finalState = 'REFUNDED';
    }

    var price = product.bestOffer.bidPrice;
    destiny.balance -= price;
    origin.balance += price;

    product.state = finalState;
 
    return getAssetRegistry('es.uva.asai.chainedbids.Product')
         .then(function(productRegistry) {
            return productRegistry.update(product);
         })
         .then(function() {
            return getParticipantRegistry('es.uva.asai.chainedbids.User')
         })
         .then(function(userRegistry) {
            return userRegistry.updateAll([origin, destiny]);
         });
 }

 /** Send a product, either normal or return
 * @param {es.uva.asai.chainedbids.ProductSending} sending - the sending
 * @transaction
 */
function sendProduct(sending) {
    var product = sending.product;

    if (product.state !== 'PAID') {
        throw new Error('Product has not been paid yet');
    }

    if (sending.carrier.type !== 'CARRIER') {
        throw new Error('Only carriers send products');
    }

    product.state = 'SENT';

    return getAssetRegistry('es.uva.asai.chainedbids.Product')
        .then(function(productRegistry) {
            return productRegistry.update(product);
        });
}

 /** Deliver a product
 * @param {es.uva.asai.chainedbids.ProductDelivery} delivery - the delivery
 * @transaction
 */
function deliverProduct(delivery) {
    var product = delivery.product;

    if (product.state !== 'SENT') {
        throw new Error('Cannot deliver a product which has not been sent');
    }

    if (delivery.carrier.type !== 'CARRIER') {
        throw new Error('Only carriers can deliver products');
    }

    product.state = 'DELIVERED';

    return getAssetRegistry('es.uva.asai.chainedbids.Product')
        .then(function(productRegistry) {
            return productRegistry.update(product);
        });
}

 /** Open an incident with a product
 * @param {es.uva.asai.chainedbids.Incident} incident - the incident
 * @transaction
 */
function openIncident(incident) {
    var product = incident.product;

    if (product.state !== 'DELIVERED') {
        throw new Error('Cannot create an issue with a product that has not been delivered');
    }

    product.state = 'TO_RETURN';

    return getAssetRegistry('es.uva.asai.chainedbids.Product')
        .then(function(productRegistry) {
            return productRegistry.update(product);
        });
}