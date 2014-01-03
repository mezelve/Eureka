// Configure Pin1 to be wake up pin
hardware.pin1.configure(DIGITAL_IN_WAKEUP);
// Set pin to PWM, with a 20 ms period and duty cycle to 1 (default)
hardware.pin9.configure(PWM_OUT, 0.02, 1.0);

// Create function to light the LED
function setLED(t,speed,pause)
{
    for(local i=0;i<t;i+=1){
        for(local nvalue=0.0; nvalue<=1.0; nvalue+=speed){//0.02
            // Write PWM value accordingly to the input value. Divide by 65535 to get a value between 0 and 1
            hardware.pin9.write(nvalue/1.0);
            imp.sleep(pause);
        }
        imp.sleep(pause);
        for(local nvalue=1.0; nvalue>=0.0; nvalue-=speed){
            // Write PWM value accordingly to the input value. Divide by 65535 to get a value between 0 and 1
            hardware.pin9.write(nvalue/1.0);
            imp.sleep(pause);
        }
    }
}
local timezone = 1;
function toAgent(){
    server.log("button pressed, hardware.voltage(): "+hardware.voltage());
    
    local d = date(time() + (timezone*60*60));
    local min = d["min"];
    local hour = d["hour"];
    local sec = d["sec"];
    if(hour<10){
        hour = "0"+hour;
    }
    if(min<10){
        min = "0"+min;
    }
    if(sec<10){
        sec = "0"+sec;
    }
    local t = hour+":"+min+":"+sec;
    //
    if(hardware.voltage()<3.0){
        agent.send("batLow",t);
    }
    //LED;
    setLED(2,0.02,0.02);
    //
    agent.send("eureka", t);
}
function getTimestamp(){
    local d = date(time() + (timezone*60*60));
    local min = d["min"];
    local hour = d["hour"];
    local sec = d["sec"];
    if(hour<10){
        hour = "0"+hour;
    }
    if(min<10){
        min = "0"+min;
    }
    if(sec<10){
        sec = "0"+sec;
    }
    local t = hour+":"+min+":"+sec;
    return t;
}
function checkVoltage(){
    local t = getTimestamp();
    server.log("checkVoltage t: "+t+", hardware.voltage(): "+hardware.voltage());
    if(hardware.voltage()<3.0){
        agent.send("batLow",t);
    }
}

if (hardware.wakereason() == WAKEREASON_PIN1) {
    server.log("Eureka!");
    toAgent();
}
checkVoltage();
imp.onidle(function() {
    server.log("idle");
    server.sleepfor(3600);
} );