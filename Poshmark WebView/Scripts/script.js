class FollowBot {

  getUserProfileLinks() {
    let tags = document.querySelectorAll("a.creator");
    let links = [];
    tags.forEach((tag) => {
      links.push(tag.href);
    });
    window.webkit.messageHandlers.FBOTuserProfileLinks.postMessage(links);
  }

  getFollowPageLink() {
    // for web it's "ul#closet-info" or for mobile "ul#m-closet-info" 
    let followers = document.querySelector("ul#m-closet-info").childNodes[2]
    followers = followers.querySelector('.count')
    let followersLink = followers.parentNode

    let followings = document.querySelector("ul#m-closet-info").childNodes[3]
    followings = followings.querySelector('.count')
    let followingsLink = followings.parentNode

    let followersCount = Number(followers.textContent.trim().split(',').join(''))
    let followingsCount = Number(followings.textContent.trim().split(',').join(''))

    if (followersCount > followingsCount) {
      followersLink.click()
    }
    else {
      followingsLink.click()
    }
  }

  scroll() {
    window.scrollBy(0,999999);
    let followList = document.querySelector(".follower-following-list")
    let timer = setTimeout(() => {
      window.scrollBy(0, -999999)
      this.followUsers();
    }, 10000)
    followList.addEventListener("DOMSubtreeModified", () => {
      window.scrollBy(0,999999);
      clearInterval(timer);
      timer = setTimeout(() => {
        window.scrollBy(0, -999999)
        this.followUsers();
      }, 10000);
    })
  }

  followUsers() {
    let users = document.querySelectorAll('#follow-user');
    var follows = 0;
    var timer;
    var timers = [];
    var followsCount = 0;
    for (let i = 0; i < users.length; i++) {
      if (users[i].getAttribute('class') === "auth-required btn blue") {
        follows++;
        timers.push(setTimeout(() => {
          follows--;
          if (follows == 0) {
            console.log(follows)
            window.webkit.messageHandlers.FBOTnextUser.postMessage("Success");
            for (let i = 0; i < timers.length; i++) {
              clearTimeout(timers[i]);
            }
          }
          if (document.querySelector("#captcha-popup") != null) {
            console.log(timer)
            window.webkit.messageHandlers.FBOTreset.postMessage("Success");
            for (let i = 0; i < timers.length; i++) {
              clearTimeout(timers[i]);
            }
          }
          users[i].click();
          followsCount++
          window.webkit.messageHandlers.FBOTfollowCountIncrement.postMessage(followsCount);
        }, 100 * follows));
      }
    }

    for (let i = 0; i < timers.length; i++) {
      timers[i];
    }
  }
}

class CommentShareBot {

  commentShare() {
    document.querySelector("textarea.username-autocomplete").value = "comment"
    document.querySelector("input.btn.add-comment").click()
    document.querySelector("a.pm-followers-share-link.grey").click()
    setTimeout(() => {
      window.webkit.messageHandlers.CSBOTnext.postMessage("Success");
    }, 2000)
  }

  getItemLinks() {
    console.log("hello")
    let tags = document.querySelectorAll("div.title-condition-con a");
    let links = [];
    tags.forEach((tag) => {
      links.push(tag.href);
    });
    window.webkit.messageHandlers.CSBOTgetItemLinks.postMessage(links);
  }

  scroll() {
    window.scrollBy(0,999999);
    let itemList = document.querySelector("#tiles-con")
    let timer = setTimeout(() => {
      window.scrollBy(0, -999999)
      this.getItemLinks();
    }, 10000)
    itemList.addEventListener("DOMSubtreeModified", () => {
      window.scrollBy(0,999999);
      clearInterval(timer);
      timer = setTimeout(() => {
        window.scrollBy(0, -999999)
        this.getItemLinks();
      }, 10000);
    })
  }
}

FBOT = new FollowBot()
CSBOT = new CommentShareBot()

