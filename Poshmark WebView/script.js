class PoshmarkBot {
  constructor() {

  }
  
  getUserProfiles() {
    let tags = document.querySelectorAll("a.creator");
    let links = [];
    tags.forEach((tag) => {
      links.push(tag.href);
    });
    window.webkit.messageHandlers.userProfileLinks.postMessage(links);
    return links;
  }

  getFollowLink() {
    // for web it's "ul#closet-info" or for mobile "ul#m-closet-info" 
    let followers = document.querySelector("ul#m-closet-info").childNodes[2]
    followers = followers.querySelector('.count')
    let followersLink = followers.parentNode
    let followersCount = Number(followers.textContent.trim().split(',').join(''))

    let followings = document.querySelector("ul#m-closet-info").childNodes[3]
    followings = followings.querySelector('.count')
    let followingsLink = followings.parentNode
    let followingsCount = Number(followings.textContent.trim().split(',').join(''))

    return followersCount > followingsCount ? followersLink : followingsLink
  }

  scroll() {
    window.scrollBy(0,10000);
    let followList = document.querySelector(".follower-following-list")
    let timer = setTimeout(() => {
      window.scrollBy(0, -100000)
      this.followUsers();
    }, 10000)
    followList.addEventListener("DOMSubtreeModified", () => {
      window.scrollBy(0,10000);
      clearInterval(timer);
      timer = setTimeout(() => {
        window.scrollBy(0, -100000)
        this.followUsers();
      }, 10000);
    })
  }

  followUsers() {/Users/admin/Desktop/Developer/Poshmark WebView/Poshmark WebView/script.js
    let users = document.querySelectorAll('#follow-user');
    var follows = 0;
    var timer;
    var timers = [];
    for (let i = 0; i < users.length; i++) {
      if (users[i].getAttribute('class') === "auth-required btn blue") {
        follows++;
        timers.push(setTimeout(() => {
          follows--;
          console.log(follows)
          if (follows == 0) {
            console.log(follows)
            window.webkit.messageHandlers.nextUser.postMessage("Success");
            for (let i = 0; i < timers.length; i++) {
              clearTimeout(timers[i]);
            }
          }
          if (document.querySelector("#captcha-popup") != null) {
            console.log(timer)
            window.webkit.messageHandlers.reset.postMessage("Success");
            for (let i = 0; i < timers.length; i++) {
              clearTimeout(timers[i]);
            }
          }
          users[i].click();
        }, 5000 * follows));
      }
    }

    for (let i = 0; i < timers.length; i++) {
      timers[i];
    }
  }
}

p = new PoshmarkBot()



