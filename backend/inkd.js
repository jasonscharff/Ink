"use strict";

var apn = require('apn');
var async = require('async');
var request = require('request');

var db = require('monk')('localhost/ink');
var users = db.get('users');

var plaid = require('plaid');
var plaidClient = new plaid.Client('56a413437119b3e14ad4a1db', '8e0268092917ad81fc98a00e27b260', plaid.environments.tartan);

var FB = require('fb');

var options = {production:false, cert: '_certs/Ink_Cert.pem' , key: '_certs/Ink_Key.pem'};

var apnConnection = new apn.Connection(options);

apnConnection.on("connected", function() {
    console.log("[APN Status] APN Connected.");
});
apnConnection.on("transmitted", function(notification, device) {
    console.log("[APN Status] Notification transmitted to:" + device.token.toString("hex"));
    apnConnection.shutdown();
});

apnConnection.on("transmissionError", function(errCode, notification, device) {
    console.error("Notification caused error: " + errCode + " for device ", device, notification);
    if (errCode === 8) {
        console.log("A error code of 8 indicates that the device token is invalid. This could be for a number of reasons - are you using the correct environment? i.e. Production vs. Sandbox");
    }
});

apnConnection.on("timeout", function () {
    console.log("Connection Timeout");
});

apnConnection.on("disconnected", function() {
    console.log("[APN Status] Disconnected from APNS");
    process.exit();
});

apnConnection.on("socketError", console.error);





users.find({}, function (err, docs){
	async.each(docs, function(single, callback2) {
		
		plaidClient.upgradeUser(single.PLAccessToken, 'connect', function (err, response) {
			if (!err) {
				plaidClient.getConnectUser(single.PLAccessToken, {gte: '30 days ago'}, function(err, plres) {
					if (!err) {
						var transJson = {total_saved: 0, amount_saved: 0, days: 0};
						var timesArray = [];
						async.each(plres.transactions, function (singletrans, callback) {
	
							var amount_saved = Math.round(((singletrans.amount)*.10) * 100) / 100;
							
							if (amount_saved < 0) 
								amount_saved = 0;
							
							
							if (Math.round(new Date(singletrans.date).getTime()/1000) > single.last_login-1296000) {
								transJson['total_saved'] += 1;
								transJson.amount_saved += amount_saved;
								timesArray.push(Math.round(new Date(singletrans.date).getTime()/1000));
							}
							callback();							
							
						}, function (err) {
							if (!err) {
								
								timesArray.sort();
								console.log(timesArray[0]);
								console.log(Math.floor(new Date() / 1000));
								transJson.days = Math.round(((Math.floor(new Date() / 1000)-timesArray[0])/86400));
								
								var avg_saved = Math.round(transJson.amount_saved/transJson.days);
								
								if (avg_saved < 5) {
									if (single.feed.length > 3) {
										
										// do something normal ish on facebook
										
									}
									if (single.apn_token) {
											var device = new apn.Device(single.apn_token);
											var note = new apn.Notification();
								
											note.expiry = Math.floor(Date.now() / 1000) + 86400; 
											note.badge = 1;
											note.sound = "ping.aiff";
											var message = "Hey " + single.fname + ". You are falling behind, continue saving money! Your average per day is: $" + avg_saved;
											note.alert = message;
											
											addtofeed(single._id, message, true);
											apnConnection.pushNotification(note, device);
									}
									
								}else {
									if (single.apn_token) {
											var device = new apn.Device(single.apn_token);
											var note = new apn.Notification();
								
											note.expiry = Math.floor(Date.now() / 1000) + 86400; 
											note.badge = 1;
											note.sound = "ping.aiff";
											var message = "Hey " + single.fname + ". You are doing great, continue saving money! Your average per day is: $" + avg_saved;
											note.alert = message;
											
											addtofeed(single._id, message, true);
											apnConnection.pushNotification(note, device);
									}
								}
							}
						});
					}
				});
			}
		});	
		
/*
		if (single.apn_token) {
			var device = new apn.Device(single.apn_token);
				var note = new apn.Notification();
	
				note.expiry = Math.floor(Date.now() / 1000) + 86400; 
				note.badge = 1;
				note.sound = "ping.aiff";
				note.alert = "Awesome! You have a 5-day steak of saving, keep it up.";
				
				apnConnection.pushNotification(note, device);
		}
		
		if (single.FBAccessToken) {
			FB.setAccessToken(req.body.fbToken);
		}
*/
		
	})
});

function addtofeed(user_id, message, penalty) {
	
	users.findById(user_id, function(err, doc) {
		if (doc.feed) {
			doc.feed.push({message: message, timestamp: Math.floor(new Date() / 1000), penalty: penalty});
		}else {
			doc.feed = [];
			doc.feed.push({message: message, timestamp: Math.floor(new Date() / 1000), penalty: penalty});
		}
		users.updateById(user_id, doc, function(err, doc) {
			
		});
	});
}