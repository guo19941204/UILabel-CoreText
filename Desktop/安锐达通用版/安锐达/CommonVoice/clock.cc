/*
 *  Copyright (c) 2013 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "clock.h"


#include <sys/time.h>
#include <time.h>

#include "tick_util.h"
#pragma comment(lib,"winmm.lib")
namespace webrtc {

const double kNtpFracPerMs = 4.294967296E6;

int64_t Clock::NtpToMs(uint32_t ntp_secs, uint32_t ntp_frac) {
  const double ntp_frac_ms = static_cast<double>(ntp_frac) / kNtpFracPerMs;
  return 1000 * static_cast<int64_t>(ntp_secs) +
      static_cast<int64_t>(ntp_frac_ms + 0.5);
}


class RealTimeClock : public Clock {
  // Return a timestamp in milliseconds relative to some arbitrary source; the
  // source is fixed for this clock.
  virtual int64_t TimeInMilliseconds() {
    return TickTime::MillisecondTimestamp();
  }

  // Return a timestamp in microseconds relative to some arbitrary source; the
  // source is fixed for this clock.
  virtual int64_t TimeInMicroseconds() {
    return TickTime::MicrosecondTimestamp();
  }

  // Retrieve an NTP absolute timestamp in seconds and fractions of a second.
  virtual void CurrentNtp(uint32_t& seconds, uint32_t& fractions) {
    timeval tv = CurrentTimeVal();
    double microseconds_in_seconds;
    Adjust(tv, &seconds, &microseconds_in_seconds);
    fractions = static_cast<uint32_t>(
        microseconds_in_seconds * kMagicNtpFractionalUnit + 0.5);
  }

  // Retrieve an NTP absolute timestamp in milliseconds.
  virtual int64_t CurrentNtpInMilliseconds() {
    timeval tv = CurrentTimeVal();
    uint32_t seconds;
    double microseconds_in_seconds;
    Adjust(tv, &seconds, &microseconds_in_seconds);
    return 1000 * static_cast<int64_t>(seconds) +
        static_cast<int64_t>(1000.0 * microseconds_in_seconds + 0.5);
  }

 protected:
  virtual timeval CurrentTimeVal() const = 0;

  static void Adjust(const timeval& tv, uint32_t* adjusted_s,
                     double* adjusted_us_in_s) {
    *adjusted_s = tv.tv_sec + kNtpJan1970;
    *adjusted_us_in_s = tv.tv_usec / 1e6;

    if (*adjusted_us_in_s >= 1) {
      *adjusted_us_in_s -= 1;
      ++*adjusted_s;
    } else if (*adjusted_us_in_s < -1) {
      *adjusted_us_in_s += 1;
      --*adjusted_s;
    }
  }
};


class UnixRealTimeClock : public RealTimeClock {
 public:
  UnixRealTimeClock() {}

  virtual ~UnixRealTimeClock() {}

 protected:
  timeval CurrentTimeVal() const {
    struct timeval tv;
    struct timezone tz;
    tz.tz_minuteswest = 0;
    tz.tz_dsttime = 0;
    gettimeofday(&tv, &tz);
    return tv;
  }
};



#warning 这里我修改了
Clock* Clock::GetRealTimeClock() {
    static UnixRealTimeClock clock;
    return &clock;
}

SimulatedClock::SimulatedClock(int64_t initial_time_us)
    : time_us_(initial_time_us) {}

int64_t SimulatedClock::TimeInMilliseconds() {
  return (time_us_ + 500) / 1000;
}

int64_t SimulatedClock::TimeInMicroseconds() {
  return time_us_;
}

void SimulatedClock::CurrentNtp(uint32_t& seconds, uint32_t& fractions) {
  seconds = (TimeInMilliseconds() / 1000) + kNtpJan1970;
  fractions = (uint32_t)((TimeInMilliseconds() % 1000) *
      kMagicNtpFractionalUnit / 1000);
}

int64_t SimulatedClock::CurrentNtpInMilliseconds() {
  return TimeInMilliseconds() + 1000 * static_cast<int64_t>(kNtpJan1970);
}

void SimulatedClock::AdvanceTimeMilliseconds(int64_t milliseconds) {
  AdvanceTimeMicroseconds(1000 * milliseconds);
}

void SimulatedClock::AdvanceTimeMicroseconds(int64_t microseconds) {
  time_us_ += microseconds;
}

};  // namespace webrtc
