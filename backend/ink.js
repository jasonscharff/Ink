var express = require('express');
var bodyParser = require('body-parser');
var async = require('async');

var jwt = require('jsonwebtoken');
var jwt_secret = '#nS{cxX)[jMFV%d3in"Rz[(CW|N?tn~oD-d+Dt--&!:R8x=5^:oikj!?j+$Q6yqU/k2bF_WO{;c;+H3w4{@G"3;PF_,7Aem3cvz%~dcRMzjasJpy"k{3-HhqOPAlDm^$';

var plaid = require('plaid');
var plaidClient = new plaid.Client('56a413437119b3e14ad4a1db', '8e0268092917ad81fc98a00e27b260', plaid.environments.tartan);

var db = require('monk')('localhost/ink');
var users = db.get('users');

var FB = require('fb');

var app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(function(req,res,next){
    res.setHeader('X-Powered-By', 'ink');
    res.setHeader('Access-Control-Allow-Origin', '*');
    next();
}); 

app.get('/', function(req, res) {
	res.send('<iframe src="https://embed.spotify.com/?uri=spotify%3Atrack%3A6c6W25YoDGjTq3qSPOga5t" width="300" height="380" frameborder="0" allowtransparency="true"></iframe>');
});

app.post('/user/login', function(req, res) {
	if (req.body.fbToken) {
		FB.setAccessToken(req.body.fbToken);
		
		FB.api('/me', { fields: ['id', 'name', 'email', 'picture', 'first_name', 'last_name'] }, function (fbres) {
			users.findOne({email: fbres.email}, function(err, doc) {
				if (doc) {
					var token = jwt.sign({id: doc._id}, jwt_secret);
					
					if (doc.PLAccessToken) {
						var hasPLToken = true;
					}else {
						var hasPLToken = false;
					}
					
					res.json({success: true, id: doc._id, auth_token: token, hasPLToken: hasPLToken});
					
				}else {
					
					var user_json = {fname: fbres.first_name, lname: fbres.last_name, email: fbres.email, FBAccessToken: req.body.fbToken, last_login: Math.floor(new Date() / 1000), id: fbres.id, picture: fbres.picture.data.url, PLAccessToken: null, StripeAccessToken: null, apn_token: req.body.apns_token, feed: [{message: "Welcome to ink!", timestamp: Math.floor(new Date() / 1000), penalty: false}]};
					
					users.insert(user_json, function(err, doc) {
						
						if (err) {
							res.status(400).send({success: false, message: err});
						}else {
							var token = jwt.sign({id: doc._id}, jwt_secret);
							res.json({success: true, id: doc._id, auth_token: token, hasPLToken: false});
						}
						
					});
					
				}
			});
		});
		
	}else {
		res.status(404).send({success: false, message: 'Login failed. Facebook id is missing.'});
	}
});

var router = express.Router();

router.use(function(req, res, next) {
	
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token) {
		jwt.verify(token, jwt_secret, function(err, decoded) {
			if (err) {
				res.status(403).send({success: false, message: 'Authentication failed. There is an issue with the token.'});
			}else {
				req.user_id = decoded.id;
				next();
			}
		});
	}else {
		res.status(403).send({success: false, message: 'Authentication failed. No token was provided.'});
	}
	
});


router.route('/user')
	.get(function(req, res) {
		res.json({user_id:req.user_id});
	});
	
router.route('/user/link')
	.post(function(req, res) {
		
		if (req.body.PLToken) {
			
			users.findById(req.user_id, function(err, doc) {
				
				if (!doc) {
					res.json({success: false});
				}else {
					plaidClient.exchangeToken(req.body.PLToken, req.body.account_id, function(err, plres) {
						if (err != null) {
							res.json({success: false, message: err});
						} else {
							doc['PLAccessToken'] = plres.access_token;
							doc['StripeAccessToken'] = plres.stripe_bank_account_token;
							users.updateById(req.user_id, doc, function(err, doc) {
								res.json({success: true});
							});
						}
					});
				}
			});
		}else {
			res.json({success: false, message: 'Plaid token missing.'});
		}
	});
	
router.route('/user/accounts')

	.get(function(req, res) {
		
		users.findById(req.user_id, function(err, doc) {
			if (doc) {
				plaidClient.getAuthUser(doc.PLAccessToken, function(err, plres) {
					if (plres) {
						
						plaidClient.upgradeUser(doc.PLAccessToken, 'connect', function (err, response) {
							if (!err) {
								plaidClient.getConnectUser(doc.PLAccessToken, {gte: '30 days ago'}, function(err, plres) {
								if (err != null) {
										res.json({success: false, message: err});
									} else {
										
										
									
										var amountSaved = 0;
										
										async.each(plres.transactions, function (single, callback) {
			
											var amount_saved = Math.round(((single.amount)*.10) * 100) / 100;
																	
											if (amount_saved < 0) 
												amount_saved = 0;
										
											if (Math.round(new Date(single.date).getTime()/1000) > doc.last_login-1296000) {
												amountSaved += amount_saved;
											}
											
											callback();
										}, function (err) {
											if (!err) {
												var tempjson = {checking:{balance: 0-amountSaved}, savings: {balance: 0+amountSaved}};
												
												async.each(plres.accounts, function (single, callback2) {
													var type = single['subtype'];
													
													if (type == 'checking') {
														tempjson.checking.balance += single.balance.available;
														callback2();
													}else if (type == 'savings') {
														tempjson.savings.balance += single.balance.available;
														callback2();
													}
													
												}, function(err) {
													if (!err) {
														
														async.each(doc.manual_transactions, function (single, callback3) {
															tempjson.savings.balance += Number(single.amount);
															tempjson.checking.balance -= Number(single.amount);
															callback3();
														},function (err){
															if (!err)
																res.json({success: true, accounts: tempjson});
														});
													}
												});
												
											}
										});
										
									}
									
								});
							}else {
								res.json({success: false, message: err});
							}
						});	
						
					}
			
				});	
			}else {
				res.json({success: false, message: 'Auth failed.'});
			}
		});
		

	});
	
router.route('/user/transactions')

	.get(function(req, res) {
		
		users.findById(req.user_id, function(err, doc) {
			if (!doc) {
				res.status(400).send({success: false, message: 'Authentication failed.'});
			}else {
				plaidClient.upgradeUser(doc.PLAccessToken, 'connect', function (err, response) {
					if (!err) {
						plaidClient.getConnectUser(doc.PLAccessToken, {gte: '30 days ago'}, function(err, plres) {
							if (err != null) {
								res.json({success: false, message: err});
							} else {
								var transJson = [];
								async.each(plres.transactions, function (single, callback) {
	
									var amount_saved = Math.round(((single.amount)*.10) * 100) / 100;
									
									if (amount_saved < 0) 
										amount_saved = 0;
									
									
									if (Math.round(new Date(single.date).getTime()/1000) > doc.last_login-1296000) {
										transJson.push({amount:single.amount, date:single.date, name:single.name, amount_saved:amount_saved});
									}else {
										transJson.push({amount:single.amount, date:single.date, name:single.name, amount_saved:0});
									}
									
									
									callback();
								}, function (err) {
									if (!err) {
										res.json({success: true, transactions: transJson});
									}
								});
								
							}
							
						});
					}else {
						res.json({success: false, message: err});
					}
				});	
			}
		});
	
	});
	
	
router.route('/user/transfer')

	.post(function(req, res) {
		
		users.findById(req.user_id, function(err, doc) {
			if (!doc) {
				res.status(400).send({success: false, message: 'Authentication failed.'});
			}else {
				
				var amount = req.body.amount;
				
				if (doc.manual_transactions) {
					doc.manual_transactions.push({amount: req.body.amount, timestamp: Math.floor(new Date() / 1000)});
				}else {
					doc.manual_transactions = []
					doc.manual_transactions.push({amount: req.body.amount, timestamp: Math.floor(new Date() / 1000)});
				}
				
				if (doc.feed) {
					doc.feed.push({message: "Congrats on commiting $" + req.body.amount + " to save!", timestamp: Math.floor(new Date() / 1000), penalty: false});
				}else {
					doc.feed = [];
					doc.feed.push({message: "Congrats on commiting $" + req.body.amount + " to save!", timestamp: Math.floor(new Date() / 1000), penalty: false});
				}
				
				users.updateById(req.user_id, doc, function(err, doc) {
					res.json({success: true});
				});
			}
		});
	
	});
	
router.route('/user/feed')

	.post(function(req, res) {
		
		users.findById(req.user_id, function(err, doc) {
			if (doc.feed) {
				doc.feed.push({message: req.body.message, timestamp: Math.floor(new Date() / 1000), penalty: req.body.isPenalty});
			}else {
				doc.feed = [];
				doc.feed.push({message: req.body.message, timestamp: Math.floor(new Date() / 1000), penalty: req.body.isPenalty});
			}
			users.updateById(req.user_id, doc, function(err, doc) {
				res.json({success: true});
			});
		});
	
	})
	.get(function(req, res) {
		
		users.findById(req.user_id, function(err, doc) {
			if (doc.feed) {
				res.json({success:true, feed: doc.feed.reverse()});
			}else {
				res.json({success:true, feed: []});
			}
			
		});

		
	});
	
app.use('/', router);
console.log("ink is alive");
exports.app = app;