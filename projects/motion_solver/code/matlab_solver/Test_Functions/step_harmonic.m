
% Function to create a stepped harmonic motion
function [tvec, pos] = step_harmonic(t0, tf, dt, amp, freq)
    tvec = 0:dt:(tf-t0);
    pos = zeros(1,length(tvec));

    for i = 1:length(pos)
        if sin(2*pi*freq*tvec(i)) > 0
            pos(i) = amp*sin(2*pi*freq*tvec(i));
        end
    end
end