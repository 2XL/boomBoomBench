

TODO,

0th download
https://github.com/2XL/PuppetEssential.git


1st make ssh push to list of clients
https://github.com/2XL/PuppetEssential

###


Pre Requisites:

- fill the data.slaves.txt with reachable domain names of target hosts
- have ssh activated at those hosts

Use cases:

- [1]preconfig => prepare the host with vagrant & virtualbox

- [2]summon => connect to each host and have them download PuppetEssential:benchbox (a vagrant project) and the boxes!!!

- [config] => push profile initial from -> 'data.slaves.profile.txt' -> to each host paired with data.slaves.txt row

- [3]run => check proj is loaded at each host, if true 1st try pull, then check if running if true provision, else up

- status =>  retrieve log file from each node from -> ~/PuppetEssential/${hostname}.log ->>> to -> ./status/*

- keepalive => remove disable auto halt script from hosts (only milax: hosts)

- scan => scan_d2xx -> port scan and update :: data.slaves.txt

- destroy => destroy the vagrant project and clean the project base

- shutdown => shutdown remote hosts!!!






