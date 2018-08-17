class PoshmarkBot {
  constructor() {
    this.userProfileLinks = this.getUserProfiles()
    this.currLinkCounter = 0
    this.currLink = this.userProfileLinks[this.currLinkCounter]
  }
  
  getUserProfiles() {
    return document.querySelectorAll("a.creator");
  }

  getFollowLink() {
    // for web it's "ul#closet-info" or for mobile "ul#m-closet-info" 
    let  followers = document.querySelector("ul#m-closet-info").childNodes[2]
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
      this.followUsers();
    }, 10000)
    followList.addEventListener("DOMSubtreeModified", () => {
      window.scrollBy(0,10000);
      clearInterval(timer);
      timer = setTimeout(() => {
        this.followUsers();
      }, 10000);
    })
  }

  followUsers() {
    let users = document.querySelectorAll('#follow-user');
    for (let i = 0; i < users.length; i++) {
      if (users[i].getAttribute('class') === "auth-required btn blue") {
        (() => {
          setTimeout(() => {
            users[i].click();
          }, 2000 * i);
        })();
      }
    }
  }

  run() {
    this.currLink.click()
    this.getFollowLink().click()
    this.scroll()
  }
}

p = new PoshmarkBot()



