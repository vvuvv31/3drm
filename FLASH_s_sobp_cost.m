function y = FLASH_s_sobp_cost(w, dist, beginIndex, endIndex, targetDose)
    totp = dist * w;
    y = sum(abs(totp(beginIndex:endIndex) - targetDose).^2);

end