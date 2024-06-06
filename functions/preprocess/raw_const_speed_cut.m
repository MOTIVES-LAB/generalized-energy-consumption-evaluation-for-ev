function T_out = raw_const_speed_cut(T,spd_c,err)

spd = T.DAActualSpeed;            % km/h
len = length(spd);

spd_c = mean(spd((spd>spd_c-3*err)&(spd<spd_c+3*err)));
ind = ones(1,2);
len_max = 1;
lim = [spd_c-err,spd_c+err];
cnt = 0;
ind_s = 0; % flag that current speed satisfy the speed limit

for i = 1:len
    if spd(i)>lim(1)&&spd(i)<lim(2)
        if ind_s == 0
            ind_s = i;
            cnt = 1;
        else
            cnt = cnt + 1;
        end
    else
        if ind_s > 0 
            if cnt>len_max
                len_max = cnt;
                ind(1) = ind_s;
                ind(2) = i-1;
            end
            ind_s = 0;
        end
    end
end
if cnt>len_max
    len_max = cnt;
    ind(1) = ind_s;
    ind(2) = i-1;
end

if len_max<6000
    warning(strcat("Only ", num2str(len_max), " samples were found for the ",num2str(spd_c)," km/h constant speed segment"))
end

T_out = T(ind(1):ind(2),:);